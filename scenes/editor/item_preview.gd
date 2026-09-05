extends TextureRect

onready var editor = owner
onready var parallax_scroll = $"%ParallaxScroll"

var offset := Vector2(16, 16)
var preview_offset := Vector2.ZERO
var is_object: bool
var position_override: bool = false


func _ready():
	is_object = editor.selected_item is PlaceableObject


func _process(delta):
	var mouse_pos = parallax_scroll.corrected_mouse_position()
	if is_object:
		if editor.pixel_lock:
			mouse_pos = Vector2(stepify(mouse_pos.x, CurrentLevelData.editor_data.pixel_snap.x), stepify(mouse_pos.y, CurrentLevelData.editor_data.pixel_snap.y))
		mouse_pos -= offset
	else:
		mouse_pos = Vector2(
			floor(parallax_scroll.corrected_mouse_position().x / 32) * 32, 
			floor(parallax_scroll.corrected_mouse_position().y / 32) * 32
		)
	
	visible = should_show_preview()
	if !position_override: 
		rect_position = mouse_pos + preview_offset


func update_item(item, palette, is_obj):
	is_object = is_obj
	if is_obj:
		texture = item.previews[palette]
	else:
		texture = item.icons[palette]
	offset = texture.get_size()/2
	preview_offset = Vector2.ZERO
	if item is PlaceableObject:
		print(item.item_name)
		print(item.preview_offset)
		preview_offset = item.preview_offset


func should_show_preview() -> bool:
	editor.get_hovered_objects()
	var cur_tool_name: String = editor.tool_manager.current_tool.name
	var is_valid_tool: bool = "Paint" in cur_tool_name or "TileLock" in cur_tool_name
	return is_valid_tool and editor.hovered_objects.empty() and editor.ui.visible
