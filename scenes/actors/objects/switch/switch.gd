extends GameObject

var pressed = false
var boost_timer = 0.0
var was_ground_pound = false

var character : Character
export var top_point : Vector2

onready var anim_player = $AnimationPlayer
onready var press_area = $PressArea

var pressed_time = 20

func _set_properties():
	savable_properties = ["pressed_time"]
	editable_properties = ["pressed_time"]

func _set_property_values():
	set_property("pressed_time", pressed_time, true)

func _ready():
	rotation = 0

func press(hit_pos : Vector2) -> void:
	if !pressed:
		pressed = true
		anim_player.play("press", -1, 2.0)
		boost_timer = 0.175

func _physics_process(delta):
	if mode == 1: return
	if enabled:
		if pressed and is_instance_valid(character) and !character.dead:
			# Mario stepped on the switch (it broke, how will he play vidya game now)
			if boost_timer > 0:
				if !was_ground_pound:
					character.velocity.y = 0
					if character.move_direction != 0:
						character.global_position.x += character.move_direction * 2
					character.global_position.y = lerp(character.global_position.y, (global_position.y + top_point.y) - 25, delta * 6)
					
					var lerp_strength = 15
					lerp_strength = clamp(abs(character.global_position.x - global_position.x), 0, 15)
					character.global_position.x = lerp(character.global_position.x, global_position.x, delta * lerp_strength)
				boost_timer -= delta
				
				if boost_timer <= 0:
					boost_timer = 0
					get_tree().get_current_scene().switch_timer = pressed_time
					if !was_ground_pound:
						character.velocity.y = -325
						if character.state != character.get_state_node("DiveState"):
							character.set_state_by_name("BounceState", delta)
			
			if get_tree().get_current_scene().switch_timer == 0 and boost_timer == 0:
				pressed = false
				anim_player.play("unpress")
		else:
			# Check the press hitbox
			for hit_body in press_area.get_overlapping_bodies():
				if hit_body.name.begins_with("Character"):
					if hit_body.velocity.y > 0 and !hit_body.swimming:
						if hit_body.big_attack or hit_body.invincible:
							was_ground_pound = true
						else:
							was_ground_pound = false
						character = hit_body
						press(hit_body.global_position)
