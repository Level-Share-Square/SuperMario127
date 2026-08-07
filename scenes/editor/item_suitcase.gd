extends HBoxContainer

export var placeable_items: Resource

onready var bottom_row = $Middle/VBoxContainer/PanelContainer/HBoxContainer
onready var editor = owner
var selected_loadout

onready var button1 = $Middle/VBoxContainer/PanelContainer/HBoxContainer/Button1
onready var button2 = $Middle/VBoxContainer/PanelContainer/HBoxContainer/Button2
onready var button3 = $Middle/VBoxContainer/PanelContainer/HBoxContainer/Button3
onready var button4 = $Middle/VBoxContainer/PanelContainer/HBoxContainer/Button4
onready var button5 = $Middle/VBoxContainer/PanelContainer/HBoxContainer/Button5
onready var button6 = $Middle/VBoxContainer/PanelContainer/HBoxContainer/Button6
onready var button7 = $Middle/VBoxContainer/PanelContainer/HBoxContainer/Button7
onready var button_container = $Middle/VBoxContainer/PanelContainer/HBoxContainer

var loadouts: Dictionary = {
	"A": ["obj_coin", "obj_mario", "til_grass", "til_brick", "obj_shine", "obj_star_coin", "obj_red_coin"],
	"B": [],
	"C": [],
	"D": [],
}

# Called when the node enters the scene tree for the first time.
func _ready():
	selected_loadout = "A"
	for item_button in button_container.get_children():
		item_button.connect("pressed", self, "_on_item_button_pressed", [item_button])
		item_button.item = placeable_items.placeable_items[loadouts[selected_loadout][item_button.get_index()]]
#func _process(delta):
#	print(editor)

func item_selected(placeable_item: Resource):
	bottom_row.move_child(bottom_row.get_children()[6], 0)
	bottom_row.get_children()[0].set_item(placeable_item)
	bottom_row.get_children()[0].visible = true

func _on_item_button_pressed(item_button):
	var item_name: String = loadouts[selected_loadout][item_button.get_index()]
	var associated_item = placeable_items.placeable_items[loadouts[selected_loadout][item_button.get_index()]]
	editor.selected_item = associated_item
#	print(editor.selected_item)
	match item_name.substr(0, 3):
		"obj":
			editor.tool_manager.change_tool("ObjectPaint")
		"til":
			editor.tool_manager.change_tool("TilePaint")

#
#func new_favorite_selected(placeable_item: Resource, button):
#	if button in top_row.get_children():
#		button.visible = false
#		top_row.move_child(button, 4)
#		return
#	top_row.move_child(top_row.get_children()[max_top - 1], 0)
#	top_row.get_children()[0].set_item(placeable_item)
#	top_row.get_children()[0].visible = true
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
