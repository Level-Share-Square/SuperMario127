class_name EditorTool
extends Control


enum Type {TileTool, ObjectTool}


export(Type) var tool_type: int
export var inverse_tool_name: String

var left_held: bool
var right_held: bool

onready var editor = get_owner()
onready var shared: LevelShared = editor.get_shared_node()


func _click(_event: InputEvent, _world_pos: Vector2) -> void:
	pass


func _click_released(_event: InputEvent, _world_pos: Vector2) -> void:
	pass


func _mouse_movement(_event: InputEvent, _world_pos: Vector2) -> void:
	pass
