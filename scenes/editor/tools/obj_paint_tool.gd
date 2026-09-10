extends EditorTool

const HOLD_TIME: float = 0.07

var last_mouse_tile: Vector2
var is_erasing: bool

var is_dragging: bool = false

var old_pos: Vector2
var pos_offset: Vector2

var hovered_object: GameObject
var is_copied: bool = false


func _click_left(_event: InputEvent, world_pos: Vector2) -> void:
	is_erasing = tool_manager.is_erasing
	_click(world_pos)


func _click_right(_event: InputEvent, world_pos: Vector2) -> void:
	is_erasing = not tool_manager.is_erasing
	_click(world_pos)


func _click(world_pos: Vector2) -> void:
	editor.get_hovered_objects()
	
	if not is_erasing:
		place_object(world_pos)
	else:
		for object in editor.hovered_objects.values():
			erase_object(object)


func place_object(pos: Vector2, data = null):
	if shared.get_object_at_position(Vector2(round(pos.x), round(pos.y)), editor.layer):
		return
	
	var object_item: PlaceableObject = editor.selected_item
	if not data:
		data = create_object_data(Vector2(round(pos.x), round(pos.y)) if editor.pixel_lock == false else pos.snapped(CurrentLevelData.editor_data.pixel_snap), object_item.object_id, object_item.palette)

	for property in object_item.property_overrides:
		if data.get_property(property) != null: continue
		
		data.set_property(property, object_item.property_overrides[property])


	var action := PlaceObjectAction.new()
	action.shared = shared
	action.layer = editor.layer
	action.object_data = data
	editor.action_manager.commit_action([action])
	
	return action.object


func create_object_data(position: Vector2, object_id: int, palette: int) -> ObjectData:
	var metadata := ObjectMetadata.new(position, object_id, palette)
	var data := ObjectData.new(metadata)
	
	return data


func erase_object(object: GameObject):
	var action := EraseObjectAction.new()
	action.shared = shared
	action.layer = editor.layer
	action.object = object
	editor.action_manager.commit_action([action])
	
func change_property(object, property: String, new_value, old_value):
	var properties: Dictionary = setup_properties(property, new_value, old_value)
	var action := ChangePropertyAction.new()
	action.object = object
	action.changed_properties = properties["changed_properties"]
	action.original_properties = properties["original_properties"]
	editor.action_manager.commit_action([action])

func setup_properties(property: String, new_value, old_value) -> Dictionary:
	var properties: Dictionary = {
		"changed_properties": {},
		"original_properties": {}
	}
	properties["changed_properties"] = {property: new_value}
	properties["original_properties"] = {property: old_value}
	return properties

