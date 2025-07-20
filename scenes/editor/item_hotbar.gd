extends HBoxContainer

export var placeable_items: Resource
onready var editor = owner

onready var bottom_row = $Middle/VBoxContainer/PanelContainer/HBoxContainer
onready var button_container = $Middle/VBoxContainer/PanelContainer/HBoxContainer
onready var loadout_container = $Middle/VBoxContainer/PanelContainer2/HBoxContainer

var selected_loadout: int = 0

var fav_items: Array = [
	[],
	[],
	[],
	[],
]

var items_favorited: Array = [0, 0, 0, 0] #Per each loadout

var loadouts: Array = [
	["obj_coin", "obj_mario", "til_grass", "til_brick", "obj_shine", "obj_star_coin", "obj_red_coin"],
	["obj_barrel_cactus", "obj_barrel_cactus", "obj_barrel_cactus", "obj_barrel_cactus", "obj_barrel_cactus", "obj_barrel_cactus", "obj_barrel_cactus"],
	["obj_barrel_cactus", "obj_barrel_cactus", "obj_barrel_cactus", "obj_barrel_cactus", "obj_barrel_cactus", "obj_barrel_cactus", "obj_barrel_cactus"],
	["obj_barrel_cactus", "obj_barrel_cactus", "obj_barrel_cactus", "obj_barrel_cactus", "obj_barrel_cactus", "obj_barrel_cactus", "obj_barrel_cactus"],
]

func _ready():
	selected_loadout = 0
	yield(get_tree().create_timer(0.1), "timeout")
	for item_button in button_container.get_children():
		item_button.connect("button_down", self, "_on_item_button_pressed", [item_button])
		item_button.item = placeable_items.placeable_items[loadouts[selected_loadout][item_button.get_index()]]
	for loadout_button in loadout_container.get_children():
		if "Loadout" in loadout_button.name:
			loadout_button.connect("button_down", self, "_on_loadout_pressed", [loadout_button])
	editor.selected_item = placeable_items.placeable_items["obj_coin"]

func _on_item_button_pressed(item_button):
	var item_name: String = loadouts[selected_loadout][item_button.get_index()]
	var associated_item = placeable_items.placeable_items[loadouts[selected_loadout][item_button.get_index()]]
	editor.selected_item = associated_item
	match item_name.substr(0, 3):
		"obj":
			editor.tool_manager.change_tool("ObjectPaint")
		"til":
			editor.tool_manager.change_tool("TilePaint")

func _process(delta):
	for item_button in button_container.get_children():
		if item_button.item == editor.selected_item:
			item_button.pressed = true
		else:
			item_button.pressed = false

func _on_loadout_pressed(loadout_button):
	match loadout_button.name:
		"LoadoutA":
			selected_loadout = 0
		"LoadoutB":
			selected_loadout = 1
		"LoadoutC":
			selected_loadout = 2
		"LoadoutD":
			selected_loadout = 3
	refresh_loadout()

func new_favorite_selected(placeable_item: Resource):
	var item_name =  placeable_items.placeable_items.find_key(placeable_item)
	if item_name in fav_items[selected_loadout]:
		loadouts[selected_loadout].insert(6, loadouts[selected_loadout].pop_at(fav_items[selected_loadout].find(item_name)))
		fav_items[selected_loadout].erase(item_name)
		items_favorited[selected_loadout] -= 1
		refresh_loadout()
		return
	fav_items[selected_loadout].append(item_name)
	loadouts[selected_loadout].remove(items_favorited[selected_loadout])
	loadouts[selected_loadout].insert(items_favorited[selected_loadout], item_name)
	items_favorited[selected_loadout] += 1
	refresh_loadout()

func _on_ItemPickerWindow_item_selected(item):
	var index = items_favorited[selected_loadout]
	bottom_row.move_child(bottom_row.get_children()[6],index)
	bottom_row.get_children()[index].item = item
	bottom_row.get_children()[index].visible = true
	loadouts[selected_loadout].insert(index, loadouts[selected_loadout].pop_back())
	loadouts[selected_loadout][index] = placeable_items.placeable_items.find_key(item)
	
func refresh_loadout():
	for item_button in button_container.get_children():
		var item = loadouts[selected_loadout][item_button.get_index()]
		if item in fav_items[selected_loadout]:
			item_button.favorite = true
		else:
			item_button.favorite = false
		item_button.item = placeable_items.placeable_items[item]
