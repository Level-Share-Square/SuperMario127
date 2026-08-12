extends Node2D


onready var playable_rect = $PlayableRect
onready var paddle = $"%Paddle"

var paused: bool


func update_branch_paused(parent: Node = self) -> void:
	for child in parent.get_children():
		if not child is Area2D:
			child.set_physics_process(not paused)
			update_branch_paused(child)


func _physics_process(_delta):
	var rect_empty: bool = true
	for overlapping_area in playable_rect.get_overlapping_areas():
		if overlapping_area.name == "PlayerCollision":
			rect_empty = false
	
	if rect_empty and not paused:
		paused = true
		update_branch_paused()
	elif not rect_empty and paused:
		paused = false
		update_branch_paused()
