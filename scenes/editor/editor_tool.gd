class_name EditorTool
extends Control


onready var editor = get_owner()
onready var shared: LevelShared = editor.get_shared_node()
var action_manager: ActionManager


func _ready():
	action_manager = editor.action_manager


func _click(_event: InputEvent, _world_pos: Vector2) -> void:
	pass


func _click_released(_event: InputEvent, _world_pos: Vector2) -> void:
	pass


func _mouse_movement(_event: InputEvent, _world_pos: Vector2) -> void:
	pass
