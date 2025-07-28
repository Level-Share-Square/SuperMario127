extends EditorWindow


const TITLE_TEXT: String = "%s Properties"

onready var window_title = $"%WindowTitle"
onready var window_icon = $"%WindowIcon"

var objects: Dictionary
var common_properties: Array
var common_property_tabs: Array


func load_objects(_objects: Dictionary):
	objects = _objects
	
	for _item in objects.keys():
		var item: PlaceableItem = _item
		var game_object = objects[item]
		
		window_title.text = TITLE_TEXT % item.item_name
		window_icon.texture = item.icons[item.palette]
	
	popup_centered(rect_size)
