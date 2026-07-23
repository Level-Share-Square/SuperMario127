extends TextureRect

onready var editor = owner

var offset := Vector2(16, 16)
var is_object: bool

func _ready():
	print(editor.selected_item is PlaceableObject)
	is_object = editor.selected_item is PlaceableObject

func _process(delta):
	var mouse_pos = get_global_mouse_position() - offset
	if is_object:
		if editor.pixel_lock:
			mouse_pos = Vector2(stepify(mouse_pos.x, 8), stepify(mouse_pos.y, 8))
	else:
		mouse_pos = Vector2(int(get_global_mouse_position().x / 32) * 32, int(get_global_mouse_position().y / 32) * 32)
	rect_global_position = mouse_pos

func update_item(item, palette, is_obj):
	is_object = is_obj
	if is_obj:
		texture = item.previews[palette]
	else:
		texture = item.icons[palette]
	offset = texture.get_size()/2


func _on_Tools_tool_changed():
	if !"Paint" in editor.tool_manager.current_tool.name:
		hide()
	else:
		show()
