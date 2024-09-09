extends GameObject

var pressed = false
var boost_timer = 0.0
var was_ground_pound = true

var character : Character
export var top_point : Vector2

onready var switch = $Switch
onready var anim_player = $AnimationPlayer
onready var press_area = $PressArea
onready var beep_sound = $Beep
onready var press_sound = $Press

var switch_mode : bool = true

var self_activated : bool = false

func _set_properties():
	savable_properties = ["switch_mode"]
	editable_properties = ["switch_mode"]

func _set_property_values():
	set_property("switch_mode", switch_mode, true)
	set_bool_alias("switch_mode", "On", "Off")

func _ready():
	beep_sound.volume_db = -80
	if mode == 1:
		press_sound.volume_db = -80
	else:
		press_sound.volume_db = 0

	rotation = 0
	switch.region_rect.position.y = palette * 21
	switch.region_rect.position.x = int(!switch_mode) * 20
	connect("property_changed", self, "_on_property_changed")
	Singleton.CurrentLevelData.level_data.vars.connect("switch_state_changed", self, "_on_switch_state_changed")
	update_switch_state()

	if Singleton.CurrentLevelData.level_data.vars.switch_state.has(palette):
		switch_mode = !switch_mode
		update_switch_state()

func press(hit_pos : Vector2) -> void:
	#print("Current_Switch_Palette: ", palette)
	if !pressed:
		pressed = true
		anim_player.play("press", -1, 2.0)
		self_activated = true
		beep_sound.volume_db = 0
		Singleton.CurrentLevelData.level_data.vars.toggle_switch_state(palette)#set_switch_state(palette, switch_mode)
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
					if !was_ground_pound:
						character.velocity.y = -325
						if character.state != character.get_state_node("DiveState"):
							character.set_state_by_name("BounceState", delta)

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

func update_switch_state():
	if !self_activated:
		if switch_mode:
			anim_player.play("depress")
			pressed = true
		else:
			pressed = false
			anim_player.play("unpress")
	self_activated = false

func _on_switch_state_changed(channel):
	if channel == palette:
		switch_mode = !switch_mode
		update_switch_state()

func _on_property_changed(key, value):
	if key == "switch_mode":
		switch.region_rect.position.x = int(!switch_mode) * 20
		update_switch_state()
