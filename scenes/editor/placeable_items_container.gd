extends TextureRect

onready var PLACEABLE_ITEM_BUTTON = load("res://scenes/editor/placeable_item_button.tscn")
export var number_of_boxes := 10
export var margin := 156
export var base_margin := 12
export var normal_color : Color
export var selected_color : Color
export var editor_node_path : NodePath 
onready var editor_node = get_node(editor_node_path)

var hovered: bool = false

func _ready():
	var placeable_items = editor_node.get_node(editor_node.placeable_items_path)
	var starting_toolbar = Singleton.CurrentLevelData.level_data.layout_ids
	var starting_toolbar_palettes = Singleton.CurrentLevelData.level_data.layout_palettes
	for index in range(number_of_boxes):
		var item
		if index < starting_toolbar.size():
			item = placeable_items.find_node(starting_toolbar[index])
			item.update_palette(starting_toolbar_palettes[index])

		var placeable_item_button = PLACEABLE_ITEM_BUTTON.instance()
		placeable_item_button.item = item
		placeable_item_button.margin = margin
		placeable_item_button.base_margin = base_margin
		placeable_item_button.button_placement = index
		placeable_item_button.placeable_items_path = "../../../PlaceableItems"
		placeable_item_button.normal_color = normal_color
		placeable_item_button.selected_color = selected_color
		placeable_item_button.box_index = index
		placeable_item_button.name = str(index)
		if index == Singleton.EditorSavedSettings.selected_box:
			editor_node.selected_box = placeable_item_button
		add_child(placeable_item_button)
	
	for child in get_children():
		
		child.connect("mouse_entered",self,"_on_mouse_entered")
		child.connect("mouse_exited",self,"_on_mouse_exited")
	
	var parent: CanvasLayer = get_parent()
	var level_settings_button: TextureButton = parent.get_node("LevelSettingsButton")
	var help_button: TextureButton = parent.get_node("HelpButton")
	var search_button: TextureButton = parent.get_node("SearchButton")
	var save_button: TextureButton = parent.get_node("SaveButton")
	var button_children: Array = [level_settings_button,help_button,search_button,save_button]
	
	for button in button_children:
		
		button.connect("mouse_entered",self,"_on_mouse_entered")
		button.connect("mouse_exited",self,"_on_mouse_exited")



func _on_mouse_entered():
	hovered = true

func _on_mouse_exited():
	hovered = false
