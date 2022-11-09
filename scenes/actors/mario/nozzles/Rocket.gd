extends Nozzle

class_name RocketNozzle

onready var cloud = preload("res://scenes/actors/objects/cloud_platform/cloud_platform.tscn")

export var clouds = 2
var cloud_index = "two"
var can_cloud_2 = true
var temp_pos_2_y = 0
var temp_pos_2_x = 0
var can_cloud_1 = true
var temp_pos_1_y = 0
var temp_pos_1_x = 0
var last_activated = false
var last_charged = false
var last_state = null

var accel = 0
var charge = 0
var rotation_interpolation_speed = 35
var deactivate_frames = 0
var cooldown_time := 0.0

func _init():
	blacklisted_states = ["GroundPoundStartState", "LavaBoostState", "GroundPoundState", "GroundPoundEndState","KnockbackState", "BonkedState"]

func _activate_check(_delta):
	return !(character.state == character.get_state_node("SwimmingState") and character.state.boost_time_left > 0) and cooldown_time == 0 and !(character.state == character.get_state_node("BackflipState") and character.state.disable_turning == true) and character.get_state_node("SlideState").crouch_buffer == 0
	
func is_state(state):
	return character.state == character.get_state_node(state)
		
func _activated_update(delta):
	match cloud_index:
		"two":
			var cloud_2 = cloud.instance()
			if can_cloud_2 == true:
				character.cloudcontain.add_child(cloud_2)
				if temp_pos_2_y == 0:
					temp_pos_2_y = cloud_2.global_position.y + 30
				if temp_pos_2_x == 0:
					temp_pos_2_x = cloud_2.global_position.x
				can_cloud_2 = false
			cloud_2.set_as_toplevel(true)
			cloud_2.global_position.y = temp_pos_2_y
			cloud_2.global_position.x = temp_pos_2_x
			yield(get_tree().create_timer(0.3), "timeout")
			cloud_index = "one"
			yield(get_tree().create_timer(4.7), "timeout")
			cloud_2.queue_free()
		"one":
			var cloud_1 = cloud.instance()
			if can_cloud_1 == true:
				character.cloudcontain.add_child(cloud_1)
				if temp_pos_1_y == 0:
					temp_pos_1_y = cloud_1.global_position.y + 30
				if temp_pos_1_x == 0:
					temp_pos_1_x = cloud_1.global_position.x
				can_cloud_1 = false
			cloud_1.set_as_toplevel(true)
			cloud_1.global_position.y = temp_pos_1_y
			cloud_1.global_position.x = temp_pos_1_x
			yield(get_tree().create_timer(0.3), "timeout")
			cloud_index = "zero"
			yield(get_tree().create_timer(4.7), "timeout")
			cloud_1.queue_free()
		
func _update(_delta):
	print(cloud_index)
