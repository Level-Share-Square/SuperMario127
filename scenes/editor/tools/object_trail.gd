extends EditorTool

const VERTEX_PATH = preload("res://scenes/editor/tools/vertex.png")

onready var curve = $"%Curve"
onready var icons = $"%Icons"
onready var widget_container = $"%WidgetContainer"

var amount: int = 3
var objects_array: Array

func _ready():
	widget_container.hide()

func _click_left(_event: InputEvent, _world_pos: Vector2):
	widget_container.show()
	curve.add_point(_world_pos)
	var texture_node = TextureRect.new()
	texture_node.texture = VERTEX_PATH
	var size = texture_node.texture.get_size()
	texture_node.rect_position = _world_pos - size/2
	icons.add_child(texture_node)
	widget_container.rect_global_position = Array(curve.points).back() + Vector2(-size.x, size.y)


func create_object_data(position: Vector2, object_id: int, palette: int) -> ObjectData:
	var data = ObjectData.new()
	data.type_id = object_id
	data.palette = palette
	data.properties.append(position)
	data.properties.append(Vector2(1, 1))
	data.properties.append(0)
	data.properties.append(true)
	data.properties.append(true)
	data.properties.append(editor.layer if editor.object_layering else LevelShared.Layers.Middle)
	
	return data
	
func _on_Tools_tool_changed():
	objects_array.clear()
	curve.clear_points()
	for icon in icons.get_children():
		icon.queue_free()
	widget_container.hide()


func _on_Check_button_down():
	for point in curve.points:
		if curve.points.size() - 1 != curve.points.find(point):
			var distance = curve.points[curve.points.find(point) + 1] - point
			var movement = distance/amount
			var new_point = point
			for objects in amount:
				new_point += movement
				var data = create_object_data(new_point, editor.selected_item.object_id, editor.selected_item.palette)
				objects_array.append(data)
	var action := PlaceObjectBulkAction.new()
	action.shared = shared
	action.objects = objects_array
	editor.action_manager.commit_action(action)
	_on_Tools_tool_changed()
