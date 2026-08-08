extends Node

onready var editor = owner
onready var shared = $"%LevelShared"
onready var object_selection = $"%ObjectSelection"
onready var hotbar = $"%Hotbar"
onready var tools = $"%Tools"

var mouse_moved: bool = false

func rotate_object():
	var hovered_objects: Dictionary = editor.get_hovered_objects()
	if !(editor.get_hovered_objects() or editor.selected_objects): return
	
	if editor.selected_objects:
		object_selection.selection_tools.call_deferred("start_tool_hotkey", "rotate_object")
		return
	object_selection.external_objects_selected(hovered_objects.values())
	object_selection.selection_tools.call_deferred("start_tool_hotkey", "rotate_object")


func scale_object():
	var hovered_objects: Dictionary = editor.get_hovered_objects()
	if !(editor.get_hovered_objects() or editor.selected_objects): return
	
	if editor.selected_objects:
		object_selection.selection_tools.call_deferred("start_tool_hotkey", "scale_object")
		return
	object_selection.external_objects_selected(hovered_objects.values())
	object_selection.selection_tools.call_deferred("start_tool_hotkey", "scale_object")

func _unhandled_input(event):
	if event is InputEventMouseMotion and event.relative != Vector2.ZERO: 
		mouse_moved = true


func flip_objects(multiplier: Vector2, objects: Array): # Hello everybody my name is
	var action := ChangePropertyBulkAction.new()
	action.affected_objects = setup_flipped_objects(multiplier, objects)
	action.bulk_store_original_properties()
	editor.action_manager.commit_action(action)

func setup_flipped_objects(multiplier: Vector2, objects) -> Dictionary:
	var affected_objects: Dictionary
	for object in objects:
		affected_objects[object] = {
			"changed_properties": {
				"scale": object.scale * multiplier
			},
			"original_properties": {}
		}
	return affected_objects
	
func disable_objects(objects: Array): # Hello everybody my name is
	var action := ChangePropertyBulkAction.new()
	action.affected_objects = setup_disabled_objects(objects)
	action.bulk_store_original_properties()
	editor.action_manager.commit_action(action)

func setup_disabled_objects(objects) -> Dictionary:
	var affected_objects: Dictionary
	for object in objects:
		affected_objects[object] = {
			"changed_properties": {
				"enabled": !object.enabled
			},
			"original_properties": {}
		}
	return affected_objects


func mirror_h():
	var hovered_objects: Dictionary = editor.get_hovered_objects()
	if !(editor.get_hovered_objects() or editor.selected_objects): return
	
	if editor.selected_objects:
		flip_objects(Vector2(-1, 1), editor.selected_objects)
		return
	flip_objects(Vector2(-1, 1), hovered_objects.values())


func mirror_v():
	var hovered_objects: Dictionary = editor.get_hovered_objects()
	if !(editor.get_hovered_objects() or editor.selected_objects): return
	
	if editor.selected_objects:
		flip_objects(Vector2(1, -1), editor.selected_objects)
		return
	flip_objects(Vector2(1, -1), hovered_objects.values())


func disable_object():
	var hovered_objects: Dictionary = editor.get_hovered_objects()
	if !(editor.get_hovered_objects() or editor.selected_objects): return
	
	if editor.selected_objects:
		disable_objects(editor.selected_objects)
		return
	disable_objects(hovered_objects.values())


func last_object():
	hotbar.hide_palettes()
	hotbar.select_last_object()


func last_tile():
	hotbar.hide_palettes()
	hotbar.select_last_tile()

func switch_item(key):
	var button = hotbar.bottom_row.get_child(key)
	
	button.emit_signal("pressed")
	button.emit_signal("button_down")
	
	yield(button.tween, "tween_completed")
	
	button.emit_signal("button_up")
	button.pressed = true


func switch_loadout(key):
	var button = hotbar.loadout_container.get_child((2*key) + 3)
	button.emit_signal("pressed")
	


func pick_focused_item():
	mouse_moved = false


func pick_focused_item_released():
	if mouse_moved == true: return

	var hovered_objects = editor.get_hovered_objects().values()
	var mouse_pos = get_node("%ParallaxScroll").corrected_mouse_position()
	var tile = shared.get_tile((mouse_pos/editor.TILE_SIZE).x, (mouse_pos/editor.TILE_SIZE).y, editor.layer)
	
	if "Object" in tools.current_tool.name and hovered_objects:
		var object = objects_util.find_closest_object(hovered_objects, mouse_pos)
		if hotbar.selected_button.item == object.placeable_item: return
		tools.change_tool("ObjectPaint")
		hotbar.select_item_from_placeable(object.placeable_item)
		
	if "Tile" in tools.current_tool.name and not shared.is_air(tile):
		var item = tile_util.get_placeable_from_tile(tile, editor.placeable_items)
		if hotbar.selected_button.item == item: return
		tools.change_tool("TilePaint")
		hotbar.select_item_from_placeable(item)
