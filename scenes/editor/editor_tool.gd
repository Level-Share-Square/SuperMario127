class_name EditorTool
extends Control


onready var editor = get_owner()
onready var shared: LevelShared = editor.get_shared_node()


func _click(_event: InputEvent, _world_pos: Vector2) -> void:
	pass


func _click_released(_event: InputEvent, _world_pos: Vector2) -> void:
	pass


func _mouse_movement(_event: InputEvent, _world_pos: Vector2) -> void:
	pass
