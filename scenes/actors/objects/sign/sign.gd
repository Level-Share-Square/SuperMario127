extends GameObject

onready var area = $MessageArea
onready var animation_player = $AnimationPlayer
onready var tween = $Tween
onready var sprite = $Sprite
onready var stick_sprite = $Stick

onready var message_appear = $MessageAppear
onready var message_disappear = $MessageDisappear

onready var pop_up = $Message
onready var panel = $Message/Panel
onready var label = $Message/Label
onready var arrow = $Message/TextureRect
onready var exclamation_mark = $Message/ExclamationMark

onready var collision_width = $InteractArea/CollisionShape2D.shape.extents.x

var slide_to_center_length := 1.25
var text := "This is a sign. Click on it in the editor to edit this text!"
var open_menu := false
var being_read := false
var character : Character

var normal_pos : Vector2
var transition_speed := 10.0
var reset_read_timer := 0.0

var check_timer := 3.0

var on_wall := false

export(Array, Texture) var palette_textures
export(Array, Texture) var palette_textures_2

func _set_properties():
	savable_properties = ["text", "open_menu", "on_wall"]
	editable_properties = ["text", "open_menu", "on_wall"]
	
func _set_property_values():
	set_property("text", text, true)
	set_property("open_menu", open_menu, true)
	set_property("on_wall", on_wall, true)

func _ready():
	if is_preview:
		z_index = 0
		sprite.z_index = 0
		stick_sprite.z_index = 0
	
	if !visible and mode != 1:
		visible = true
		sprite.visible = false
	
	if palette != 0:
		sprite.texture = palette_textures[palette - 1]
		stick_sprite.texture = palette_textures_2[palette - 1]
	
	if !enabled:
		pop_up.visible = false
		
	if open_menu:
		panel.visible = false
		label.visible = false
		arrow.visible = false
		exclamation_mark.visible = true
		animation_player.play("bobbin") # exclamation mark fucking bobbin
		area = $InteractArea
	
	normal_pos = pop_up.position
	pop_up.position = Vector2(normal_pos.x * 0.8, normal_pos.y * 0.7)
	pop_up.scale = Vector2(0.8, 0.8)
	pop_up.modulate = Color(1, 1, 1, 0)
	label.bbcode_text = "[center]" + text + "[/center]"
	if mode != 1:
		var _connect = area.connect("body_entered", self, "enter_area")
		var _connect2 = area.connect("body_exited", self, "exit_area")

func enter_area(body):
	if body.name.begins_with("Character") and character == null and enabled:
		character = body
		label.bbcode_text = "[center]" + text_replace_util.parse_text(text, character) + "[/center]"
		message_appear.play()
		
func exit_area(body):
	if body == character and character.get_collision_layer_bit(1) and enabled:
		character = null
		if reset_read_timer == 0:
			message_disappear.play()
		
func setup_char():
	character.set_dive_collision(false)
	character.invulnerable = true 
	character.controllable = false
	character.movable = false
	character.velocity = Vector2.ZERO
	character.sprite.rotation = 0
	character.set_collision_layer_bit(1, false) # disable collisions w/ most things
	character.set_inter_player_collision(false)
	character.camera.smoothing_enabled = true # Re-enable camera smoothing
	
	character.sprite.animation = "enterDoor" + ("Right" if character.facing_direction == 1 else "Left")
	character.sprite.playing = true
	
	var slide_length : float = slide_to_center_length
	
	#calculate the amount of time it should take based on the players distance from the center
	var distance_from_center_normalized : float = abs((character.position.x - global_position.x)) / collision_width 
	distance_from_center_normalized = clamp(distance_from_center_normalized, 0.1, 1)
	slide_length = slide_to_center_length * distance_from_center_normalized
	
	# warning-ignore: return_value_discarded
	tween.interpolate_property(character, "position:x", null, global_position.x, slide_length, Tween.TRANS_QUART, Tween.EASE_OUT)
	# warning-ignore: return_value_discarded
	tween.interpolate_callback(self, slide_length / 2.75, "open_menu_ui")

	# warning-ignore: return_value_discarded
	tween.start()
	
func restore_control():
	character.velocity = Vector2.ZERO
	character.invulnerable = false 
	character.controllable = true
	character.movable = true
	
	character.get_state_node("JumpState").jump_buffer = 0 # prevent character from jumping right after closing menu
	character.inputs[Character.input_names.jump][1] = false

	character.set_collision_layer_bit(1, true)
	character.set_inter_player_collision(true) 
	
	character.sprite.animation = "exitDoor" + ("Right" if character.facing_direction == 1 else "Left")
	character.sprite.playing = true
	
func open_menu_ui():
	get_tree().get_current_scene().get_node("UI/SignText").open(text, self, character)

func _physics_process(delta):
	if !sprite.visible and mode != 1:
		stick_sprite.visible = false
	else:
		stick_sprite.visible = !on_wall
		sprite.modulate = Color(0.75, 0.75, 0.75) if on_wall else Color(1, 1, 1)
	
	if reset_read_timer > 0:
		reset_read_timer -= delta
		if reset_read_timer <= 0:
			reset_read_timer = 0
			being_read = false
	
	if character == null or being_read: 
		pop_up.position = lerp(pop_up.position, Vector2(normal_pos.x * 0.8, normal_pos.y * 0.9), delta * transition_speed)
		pop_up.scale = lerp(pop_up.scale, Vector2(0.8, 0.8), delta * transition_speed)
		pop_up.modulate = lerp(pop_up.modulate, Color(1, 1, 1, 0), delta * transition_speed)
	else:
		pop_up.position = lerp(pop_up.position, normal_pos, delta * transition_speed)
		pop_up.scale = lerp(pop_up.scale, Vector2(1, 1), delta * transition_speed)
		pop_up.modulate = lerp(pop_up.modulate, Color(1, 1, 1, 1), delta * transition_speed)
		
		if (open_menu and character.inputs[Character.input_names.interact][0]
		and !character.inputs[Character.input_names.left][0]
		and !character.inputs[Character.input_names.right][0]
		and character.is_grounded() and !being_read):
			being_read = true
			setup_char()
	
	check_timer -= delta
	if check_timer <= 0:
		check_timer = 3.0
		
		var has_char = false
		for body in area.get_overlapping_bodies():
			if body is Character:
				has_char = true
		
		if !has_char and is_instance_valid(character):
			exit_area(character)
