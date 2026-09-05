class_name Dialog

extends Node2D

const DIALOGUE_GROUP: String = "TaggedDialogue"

onready var area = $InteractArea
onready var animation_player = $AnimationPlayer
onready var tween = $Tween
onready var timer = $Timer
onready var sprite = $Sprite

onready var message_appear = $MessageAppear
onready var message_disappear = $MessageDisappear
onready var camera_focus = $CameraFocus

onready var pop_up = $Indicator
onready var exclamation_mark = $Indicator/ExclamationMark

onready var interact_shape = $InteractArea/CollisionShape2D
onready var dialogue_menu = get_tree().get_current_scene().get_node_or_null("%DialogueText")

const AUTOSTART_OFF = 0
const AUTOSTART_ON = 1
const AUTOSTART_ONESHOT = 2

var dialogue
var character_name
var autostart: int = 0
var tag: String
var delegate_tag: String
var zoom_size: float = 0.65
var stored_zoom := Vector2.ONE

var page_cache: int = 0
var being_read := false
var has_been_read := false
var interactable := true
var body_overlapping := false
var characters: Array = []
var parent

var normal_pos : Vector2
var transition_speed := 10.0
var reset_read_timer := 0.0

var check_timer := 3.0

signal message_appear
signal message_disappear
signal message_changed(expression, action)


func add_character(character: Character)-> void:
	
	remove_character(character)
	characters.append(character)

func remove_character(character: Character)-> void:
	
	characters.erase(character)

func get_interacting_character()-> Character:
	
	for character in characters:
		if (body_overlapping
		and character.inputs[Character.input_names.interact][1]
		and !character.inputs[Character.input_names.left][0]
		and !character.inputs[Character.input_names.right][0]
		and character.is_grounded() and character.controllable
		and !being_read and interactable):
			return character
	
	return null

func initialize():
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
	pop_up.reset_physics_interpolation()
	if parent.mode != 1:
		var _connect = area.connect("body_entered", self, "body_entered")
		var _connect2 = area.connect("body_exited", self, "body_exited")
		yield(get_tree(), "idle_frame")
		var _connect3 = area.connect("area_entered", self, "area_entered")
		var _connect4 = area.connect("area_exited", self, "area_exited")
		
		sprite.visible = false
		if "speaking_radius" in parent:
			interact_shape.shape.radius = parent.speaking_radius
		if "autostart" in parent:
			autostart = parent.autostart
		if "interactable" in parent:
			interactable = parent.interactable
			if not interactable: hide()
		if "tag" in parent and parent.tag != "":
			tag = parent.tag
			add_to_group(DIALOGUE_GROUP)
		if "delegate_tag" in parent:
			delegate_tag = parent.delegate_tag
		if "zoom_size" in parent:
			zoom_size = parent.zoom_size


func connect_menu_oneshot():
	if not dialogue_menu.is_connected("menu_closed", self, "menu_closed"):
		dialogue_menu.connect("menu_closed", self, "menu_closed", [], CONNECT_ONESHOT)

func open_remote_menu(new_char: Character):
	if being_read: return
	being_read = true
	connect_menu_oneshot()
	# calls immediately so it can
	# override mario's inputs
	get_tree().call_group_flags(
		SceneTree.GROUP_CALL_REALTIME,
		DIALOGUE_GROUP,
		"open_menu_conditional", new_char, delegate_tag
	)


func open_menu_conditional(new_char: Character, compare_tag: String):
	if tag != compare_tag: return
	open_menu(new_char)

func open_menu(new_char: Character):
	if being_read: return
	add_character(new_char)
	being_read = true
	connect_menu_oneshot()
	open_menu_ui(new_char)
	
	var players: Array = get_tree().root.get_node("Player").get_characters()
	for player in players:
		setup_char(player)


func menu_closed():
	
	var players: Array = get_tree().root.get_node("Player").get_characters()
	for player in players:
		if is_instance_valid(player) and not player.controllable:
			restore_control(player)
	reset_read_timer = 0.5
	has_been_read = true
	page_cache = 0


func body_entered(body):
	if not interactable: return
	if not is_visible_in_tree(): return
	if not parent.enabled: return
	if being_read: return
	if body.name.begins_with("Character"):
		body_overlapping = true
		add_character(body)
		if (len(characters) == 1):
			message_appear.play()
		timer.start()

func body_exited(body):
	if being_read: return
	for character in characters:
		if character.get_collision_layer_bit(1):
			message_disappear.play()
			body_overlapping = false
			remove_character(body)
			timer.stop()

func autostart_dialogue(body):
	if autostart > AUTOSTART_OFF and body.name.begins_with("PlayerCollision"):
		if autostart == AUTOSTART_ONESHOT and has_been_read == true: return
		
		var new_char: Character = body.get_parent()
		if not new_char.controllable: return
		
		dialogue_menu.stored_velocity = new_char.velocity
		if delegate_tag == "" or delegate_tag == tag:
			open_menu(new_char)
		else:
			open_remote_menu(new_char)


# this is to make npcs emote in front of signs (and run autostart now lol)
func area_entered(body):
	# "area" is already taken and im too lazy to change it
	var area_parent = body.get_parent()
	
	if !(area_parent is Character): return
	
	#check if autostart is on (should be above AUTOSTART_OFF which is 0)
	autostart_dialogue(body)
	
	if area_parent.has_signal("message_appear") and area_parent.has_signal("message_disappear"):
		area_parent.connect("message_appear", parent, "start_talking")
		area_parent.connect("message_disappear", parent, "stop_talking")

func area_exited(body):
	var area_parent = body.get_parent()
	
	if !(area_parent is Character): return
	
	if area_parent.has_signal("message_appear") and area_parent.has_signal("message_disappear"):

		area_parent.disconnect("message_appear", parent, "start_talking")
		area_parent.disconnect("message_disappear", parent, "stop_talking")

func setup_char(character: Character):
	
	# flip mario to face this object
	character.facing_direction = sign(parent.global_position.x - character.global_position.x)
	
	if character.controllable:
		stored_zoom = character.camera.current_zoom
	
	character.set_dive_collision(false)
	character.invulnerable = true
	character.controllable = false
	character.velocity = Vector2.ZERO
#	character.set_collision_layer_bit(1, false) # disable collisions w/ most things
	character.set_inter_player_collision(false)
	
	character.camera.set_zoom_tween(Vector2(zoom_size, zoom_size), 1)
	character.camera.focus_on = camera_focus
	
	# sadly, i can't think of a cleaner way to get him to actually
	# face the camera at the moment; even setting the sprite direction
	# manually doesn't do anything without these two lines
	yield(get_tree(), "idle_frame")
	character.movable = false

func restore_control(character: Character):
	character.invulnerable = false
	character.controllable = true
	character.auto_flip = true
	character.movable = true
	
	character.get_state_node("JumpState").jump_buffer = 0 # prevent character from jumping right after closing menu
	character.inputs[Character.input_names.jump][1] = false

	character.set_collision_layer_bit(1, true)
	character.set_inter_player_collision(true)

	character.camera.zoom_tween.remove_all()
	character.camera.set_zoom_tween(stored_zoom, 0.5)
	character.camera.focus_on = null

func open_menu_ui(character: Character):
	dialogue_menu.open(dialogue, self, character, character_name)

func _physics_process(delta):

	if reset_read_timer > 0:
		reset_read_timer -= delta
		if reset_read_timer <= 0:
			reset_read_timer = 0
			being_read = false
			
			if not sprite.visible: 
				emit_signal("message_disappear")
	
	if not body_overlapping or being_read: 
		pop_up.position = lerp(pop_up.position, Vector2(normal_pos.x * 0.8, normal_pos.y * 0.9), delta * transition_speed)
		pop_up.scale = lerp(pop_up.scale, Vector2(0.8, 0.8), delta * transition_speed)
		pop_up.modulate = lerp(pop_up.modulate, Color(1, 1, 1, 0), delta * transition_speed)
	else:
		pop_up.position = lerp(pop_up.position, normal_pos, delta * transition_speed)
		pop_up.scale = lerp(pop_up.scale, Vector2(1, 1), delta * transition_speed)
		pop_up.modulate = lerp(pop_up.modulate, Color(1, 1, 1, 1), delta * transition_speed)
		
		# :/
		var character_interacting: Character = get_interacting_character()
		if (is_instance_valid(character_interacting) and character_interacting in area.get_overlapping_bodies()):
			if delegate_tag == "" or delegate_tag == tag:
				open_menu(character_interacting)
			else:
				open_remote_menu(character_interacting)
		else:
			if is_instance_valid(character_interacting):
				message_disappear.play()
				body_overlapping = false
				remove_character(character_interacting)
				timer.stop()
		
		# message appear signal was removed from here, made
		# redundant by the message changed signal
	
	check_timer -= delta
	if check_timer <= 0:
		check_timer = 3.0
		
		var has_char = false
		for body in area.get_overlapping_bodies():
			if body is Character:
				has_char = true
			
		
#		if !has_char and len(characters) > 0:
#			remove_all_characters()

## check periodically that the characters still there
func on_timer_timeout():
	if len(characters) == 0: return
#	if area.get_overlapping_bodies().size() <= 0:
#		remove_all_characters()
