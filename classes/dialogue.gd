class_name Dialog

extends Node2D

onready var area = $InteractArea
onready var animation_player = $AnimationPlayer
onready var tween = $Tween
onready var sprite = $Sprite

onready var message_appear = $MessageAppear
onready var message_disappear = $MessageDisappear
onready var camera_focus = $CameraFocus

onready var pop_up = $Indicator
onready var exclamation_mark = $Indicator/ExclamationMark

onready var interact_shape = $InteractArea/CollisionShape2D

var dialogue
var character_name

var being_read := false
var character : Character
var parent

var normal_pos : Vector2
var transition_speed := 10.0
var reset_read_timer := 0.0

var check_timer := 3.0

# these are for toads
signal message_appear
signal message_disappear
signal message_changed


func _ready():
	parent = get_parent()
	assert("dialogue" in parent, "Improper use of Dialogue prefab! Must have a dialogue variable")
	assert("character_name" in parent, "Improper use of Dialogue prefab! Must have a character_name variable")
	dialogue = parent.dialogue
	character_name = parent.character_name
	
	if !parent.enabled:
		pop_up.visible = false
	
	if !visible and parent.mode != 1:
		visible = true
		sprite.visible = false
	
	animation_player.play("bobbin") # exclamation mark fucking bobbin
	
	normal_pos = pop_up.position
	pop_up.position = Vector2(normal_pos.x * 0.8, normal_pos.y * 0.7)
	pop_up.scale = Vector2(0.8, 0.8)
	pop_up.modulate = Color(1, 1, 1, 0)
	if parent.mode != 1:
		var _connect = area.connect("body_entered", self, "body_entered")
		var _connect2 = area.connect("body_exited", self, "body_exited")
		yield(get_tree(), "idle_frame")
		var _connect3 = area.connect("area_entered", self, "area_entered")
		var _connect4 = area.connect("area_exited", self, "area_exited")
		connect("message_changed", parent, "message_changed")
		connect("message_appear", parent, "start_talking")
		connect("message_disappear", parent, "stop_talking")

		
		sprite.visible = false
		if "speaking_radius" in parent:
			interact_shape.shape.radius = parent.speaking_radius

func body_entered(body):
	
	if body.name.begins_with("Character") and character == null and parent.enabled:
		character = body
		message_appear.play()
		
func body_exited(body):
	if body == character and character.get_collision_layer_bit(1) and parent.enabled:
		character = null
		if reset_read_timer == 0:
			message_disappear.play()

# this is to make npcs emote in front of signs
func area_entered(body):
	# "area" is already taken and im too lazy to change it
	var area_parent = body.get_parent()
	if area_parent.has_signal("message_appear") and area_parent.has_signal("message_disappear"):

		area_parent.connect("message_appear", parent, "start_talking")
		area_parent.connect("message_disappear", parent, "stop_talking")

func area_exited(body):
	var area_parent = body.get_parent()
	if area_parent.has_signal("message_appear") and area_parent.has_signal("message_disappear"):

		area_parent.disconnect("message_appear", parent, "start_talking")
		area_parent.disconnect("message_disappear", parent, "stop_talking")
		
func setup_char():
	# flip mario to face this object
	character.facing_direction = sign(parent.global_position.x - character.global_position.x)
	
	character.set_dive_collision(false)
	character.invulnerable = true 
	character.controllable = false
	character.velocity = Vector2.ZERO
	character.set_collision_layer_bit(1, false) # disable collisions w/ most things
	character.set_inter_player_collision(false)
	character.camera.smoothing_enabled = true # Re-enable camera smoothing
	
	character.camera.set_zoom_tween(Vector2(0.65, 0.65), 1)
	character.camera.focus_on = camera_focus
	
	open_menu_ui()
	
	# sadly, i can't think of a cleaner way to get him to actually
	# face the camera at the moment; even setting the sprite direction
	# manually doesn't do anything without these two lines
	yield(get_tree(), "idle_frame")
	character.movable = false

func restore_control():
	character.velocity = Vector2.ZERO
	character.invulnerable = false 
	character.controllable = true
	character.movable = true
	
	character.get_state_node("JumpState").jump_buffer = 0 # prevent character from jumping right after closing menu
	character.inputs[Character.input_names.jump][1] = false

	character.set_collision_layer_bit(1, true)
	character.set_inter_player_collision(true)

	character.camera.zoom_tween.remove_all()
	character.camera.set_zoom_tween(Vector2(1, 1), 0.5)
	character.camera.focus_on = null
	
func open_menu_ui():
	get_tree().get_current_scene().get_node("UI/DialogueText").open(dialogue, self, character, character_name)

func _physics_process(delta):

	if reset_read_timer > 0:
		reset_read_timer -= delta
		if reset_read_timer <= 0:
			reset_read_timer = 0
			being_read = false
			
			# related to toads
			if not sprite.visible: emit_signal("message_disappear")
	
	if character == null or being_read: 
		pop_up.position = lerp(pop_up.position, Vector2(normal_pos.x * 0.8, normal_pos.y * 0.9), delta * transition_speed)
		pop_up.scale = lerp(pop_up.scale, Vector2(0.8, 0.8), delta * transition_speed)
		pop_up.modulate = lerp(pop_up.modulate, Color(1, 1, 1, 0), delta * transition_speed)
	else:
		pop_up.position = lerp(pop_up.position, normal_pos, delta * transition_speed)
		pop_up.scale = lerp(pop_up.scale, Vector2(1, 1), delta * transition_speed)
		pop_up.modulate = lerp(pop_up.modulate, Color(1, 1, 1, 1), delta * transition_speed)
		
		# :/
		if (character.inputs[Character.input_names.interact][0]
		and !character.inputs[Character.input_names.left][0]
		and !character.inputs[Character.input_names.right][0]
		and character.is_grounded() and character.controllable
		and !being_read):
			being_read = true
			setup_char()
			
			# message appear signal was removed from here, made
			# redundant by the message changed signal
	
	check_timer -= delta
	if check_timer <= 0:
		check_timer = 3.0
		
		var has_char = false
		for body in area.get_overlapping_bodies():
			if body is Character:
				has_char = true
			
		
		if !has_char and is_instance_valid(character):
			body_exited(character)
