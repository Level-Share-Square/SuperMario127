extends HBoxContainer

export var placeable_items: Resource
onready var editor = owner

onready var bottom_row = $Middle/VBoxContainer/PanelContainer/HBoxContainer
onready var button_container = $Middle/VBoxContainer/PanelContainer/HBoxContainer
onready var loadout_container = $Middle/VBoxContainer/PanelContainer2/HBoxContainer
onready var palette_container = $"%PaletteContainer"
onready var palettes = $"%Palettes"
onready var item_preview = $"%ItemPreview"

var selected_loadout: int = 0

var fav_items: Array = [
	[],
	[],
	[],
	[],
]

var items_favorited: Array = [0, 0, 0, 0] #Per each loadout

var loadouts: Array = [
	["obj_coin", "obj_mario", "til_grass", "til_brick", "obj_shine", "obj_star_coin", "obj_red_coin", "obj_blue_coin", "obj_barrel_cactus", "til_cabin_window"],
	["obj_barrel_cactus", "obj_barrel_cactus", "obj_barrel_cactus", "obj_barrel_cactus", "obj_barrel_cactus", "obj_barrel_cactus", "obj_barrel_cactus", "obj_barrel_cactus", "obj_barrel_cactus", "obj_barrel_cactus"],
	["obj_barrel_cactus", "obj_barrel_cactus", "obj_barrel_cactus", "obj_barrel_cactus", "obj_barrel_cactus", "obj_barrel_cactus", "obj_barrel_cactus", "obj_barrel_cactus", "obj_barrel_cactus", "obj_barrel_cactus"],
	["obj_barrel_cactus", "obj_barrel_cactus", "obj_barrel_cactus", "obj_barrel_cactus", "obj_barrel_cactus", "obj_barrel_cactus", "obj_barrel_cactus", "obj_barrel_cactus", "obj_barrel_cactus", "obj_barrel_cactus"],
]

var loadout_palettes: Array = [
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
]

func _ready():
	bottom_row.show()
	palette_container.hide()
	bottom_row.get_children()[0].pressed = true
	selected_loadout = 0
	
	for item_button in button_container.get_children():
		item_button.connect("button_down", self, "_on_item_button_pressed", [item_button])
		item_button.change_item(placeable_items.placeable_items[loadouts[selected_loadout][item_button.get_index()]])
	
	for loadout_button in loadout_container.get_children():
		if "Loadout" in loadout_button.name:
			loadout_button.connect("button_down", self, "_on_loadout_pressed", [loadout_button])
		else:
			loadout_button.connect("button_down", self, "_on_palettes_pressed")
	
	
	if CurrentLevelData.editor_data.loadouts != []:
		loadouts = CurrentLevelData.editor_data.loadouts
		fav_items = CurrentLevelData.editor_data.fav_items
		loadout_palettes = CurrentLevelData.editor_data.palettes
		items_favorited = CurrentLevelData.editor_data.favorites
#	print(loadout_palettes)
	refresh_loadout()
	check_items()

	editor.selected_item = bottom_row.get_children()[0].item

func _on_item_button_pressed(item_button):
	var item_name: String = loadouts[selected_loadout][item_button.get_index()]
	var associated_item = placeable_items.placeable_items[loadouts[selected_loadout][item_button.get_index()]]
	if associated_item == editor.selected_item:
		item_button.timer_start = true
	editor.selected_item = associated_item
	editor.selected_item.palette = item_button.palette
	match item_name.substr(0, 3):
		"obj":
			editor.tool_manager.change_tool("ObjectPaint")
			item_preview.update_item(associated_item, associated_item.palette, true)
		"til":
			editor.tool_manager.change_tool("TilePaint")
			item_preview.update_item(associated_item, associated_item.palette, false)
	

func update_level_data():
	CurrentLevelData.editor_data.loadouts = loadouts
	var loadout_palette: PoolIntArray = PoolIntArray()
	for buttons in bottom_row.get_children():
		loadout_palette.append(buttons.palette)
	loadout_palettes[selected_loadout] = loadout_palette
#	print(loadout_palettes[selected_loadout])
	CurrentLevelData.editor_data.palettes = loadout_palettes
	CurrentLevelData.editor_data.favorites = items_favorited
	CurrentLevelData.editor_data.fav_items = fav_items


func check_items():
	for item_button in button_container.get_children():
		if item_button.item == editor.selected_item:
			item_button.pressed = true
		item_button.palette = loadout_palettes[selected_loadout][item_button.get_index()]
#		print(item_button.get_index())
		item_button.icon_node.texture = item_button.item.icons[item_button.palette]
	
	return


func _on_loadout_pressed(loadout_button):
	var loadout_palette: Array = []
	for buttons in bottom_row.get_children():
		loadout_palette.append(buttons.palette)
	loadout_palettes[selected_loadout] = loadout_palette
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
	check_items()


func new_favorite_selected(placeable_item: Resource, index: int):
	var boxes: Array = bottom_row.get_children()
	var item_name =  placeable_items.placeable_items.find_key(placeable_item)
	
	if index < fav_items[selected_loadout].size():
		loadouts[selected_loadout].insert(items_favorited[selected_loadout] - 1, loadouts[selected_loadout].pop_at(fav_items[selected_loadout].find(item_name)))
		bottom_row.move_child(boxes[index], items_favorited[selected_loadout] - 1)
		fav_items[selected_loadout].erase(item_name)
		items_favorited[selected_loadout] -= 1
		refresh_loadout()
		return
	
	fav_items[selected_loadout].append(item_name)
	loadouts[selected_loadout].remove(index)
	loadouts[selected_loadout].insert(items_favorited[selected_loadout], item_name)
	bottom_row.move_child(boxes[index], items_favorited[selected_loadout])
	items_favorited[selected_loadout] += 1
	refresh_loadout()
	


func on_item_selected(item: PlaceableItem):
	var start_index: int = items_favorited[selected_loadout]
	var boxes: Array = bottom_row.get_children()
	var selected_box: Button = boxes[start_index]
	selected_box.change_item(item)
	selected_box.visible = true
	boxes[9].palette = 0
	bottom_row.move_child(boxes[9], start_index)
	loadouts[selected_loadout].insert(start_index, loadouts[selected_loadout].pop_back())
	loadouts[selected_loadout][start_index] = placeable_items.placeable_items.find_key(item)
	refresh_loadout()
	_on_item_button_pressed(boxes[9])

	boxes[9].set_deferred("pressed", true)


func refresh_loadout():
	var favs_amount: int = fav_items[selected_loadout].size()
	for item_button in button_container.get_children():
		var item = loadouts[selected_loadout][item_button.get_index()]
		item_button.set_favorite(favs_amount > 0)
		item_button.change_item(placeable_items.placeable_items[item])
		favs_amount -= 1
	


func _on_palettes_pressed():
	bottom_row.visible = palettes.pressed
	palette_container.visible = !palettes.pressed
	var palette_count: int = editor.selected_item.icons.size() - 1
	var item_palettes: Array = editor.selected_item.icons

	for palette_button in palette_container.get_children():
		palette_button.item = editor.selected_item
		if palette_button.get_index() < item_palettes.size():
			palette_button.show()
			palette_button.icon_node.texture = item_palettes[palette_button.get_index()]
		else:
			palette_button.hide()
	


func palette_selected(palette):
	bottom_row.show()
	palette_container.hide()
	palettes.pressed = false
	
	for item_button in bottom_row.get_children():
		if item_button.pressed:
			item_button.palette = palette
			editor.selected_item.palette = palette
			item_button.icon_node.texture = editor.selected_item.icons[palette]
			_on_item_button_pressed(item_button)
	
