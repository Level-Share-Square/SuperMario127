extends TeleportObject


onready var sprite = $Sprite

export var normal_texture : Texture


signal pipe_animation_finished
signal exit

onready var area2d : Area2D = $Area2D
onready var collision_shape = $Area2D/CollisionShape2D
onready var camera_stopper = $CameraStopper
onready var camera_stop_shape = $CameraStopper/CollisionShape2D
var vertical = true
var parts = 1
var stops_camera = true
var is_idle := true
var entering := false

var stored_characters : Array = [null, null]

func _set_properties():
	savable_properties = ["area_id", "destination_tag", "teleportation_mode", "vertical", "parts", "stops_camera", "force_fadeout"]
	editable_properties = ["area_id", "destination_tag", "teleportation_mode", "vertical", "parts", "stops_camera", "force_fadeout"]
	
func _set_property_values():
	set_property("area_id", area_id, true, "Area Destination")
	set_property("destination_tag", destination_tag, true)
	set_property("teleportation_mode", teleportation_mode, true, "Teleport Mode")
	set_bool_alias("teleportation_mode", "Remote", "Local")
	set_property("vertical", vertical)
	set_property("parts", parts)
	set_property("stops_camera", stops_camera)
	set_property("force_fadeout", force_fadeout)
#	set_property("instant", instant, true, "Instant (Local)")
	
func _init():
	teleportation_mode = true
	object_type = "area_transition"

# i tried writing this script from scratch multiple times but it never worked so i just copied the pipe script but i was too lazy to remove the word pipe from everything
func _ready():
	.ready() #Calls parent class "TeleportObject"
	connect("property_changed", self, "_on_property_changed")
	Singleton.CurrentLevelData.level_data.vars.teleporters.append([destination_tag.to_lower(), self])
	if mode == 1:
		var _connect2 = connect("property_changed", self, "update_property")
		sprite.visible = true
	else:
		sprite.visible = false
	if parts < 1:
		parts = 1
	update_property("vertical", vertical)
	camera_stopper.set_size(camera_stop_shape.shape.extents)
	camera_stopper.monitorable = stops_camera
	camera_stopper.visible = stops_camera
	
	# waits to connect to stop frame 1 teleport bugs
	yield(get_tree().create_timer(1.0), "timeout")
	$Area2D.connect("body_entered", self, "_on_body_entered")

func _input(event):
	if event is InputEventMouseButton and event.is_pressed() and hovered:
		if event.button_index == 5: # Mouse wheel down
			parts -= 1
			if parts < 1:
				parts = 1
			set_property("parts", parts, true)
		elif event.button_index == 4: # Mouse wheel up
			parts += 1
			set_property("parts", parts, true)
			
func update_property(key, value):
	match(key):
		"parts":
			if value < 1:
				parts = 1
				return
			update_parts()
		"vertical":
			if vertical:
				sprite.rect_size.x = 32
				sprite.rect_position.x = -16
				collision_shape.shape.extents.x = 16
				camera_stop_shape.shape.extents.x = 52
			else:
				sprite.rect_size.y = 32
				sprite.rect_position.y = -16
				collision_shape.shape.extents.y = 16
				camera_stop_shape.shape.extents.y = 52
			update_parts()
		"rotation_degrees":
			rotation_degrees = 0
		"stops_camera":
			camera_stopper.visible = stops_camera
			
func update_parts():
	if vertical:
		sprite.rect_size.y = parts * 32
		sprite.rect_position.y = (-16 * parts)
		collision_shape.shape.extents.y = 16 * parts
		camera_stop_shape.shape.extents.y = collision_shape.shape.extents.y + 26
	else:
		sprite.rect_size.x = parts * 32
		sprite.rect_position.x = (-16 * parts)
		collision_shape.shape.extents.x = 16 * parts
		camera_stop_shape.shape.extents.x = collision_shape.shape.extents.x + 26
			
func connect_local_members():
	connect("pipe_animation_finished", self, "_start_local_transition")
	connect("exit", self, "_start_local_transition")
	area2d.connect("body_exited", self, "exit_remote_teleport")

func connect_remote_members():
	connect("pipe_animation_finished", self, "change_areas")
	
	

func exit_local_teleport(character = null):
	pass
	

func exit_remote_teleport(character = null):
	is_idle = true


func start_exit_anim(character):
	start_pipe_exit_animation(character, teleportation_mode)



func _on_property_changed(key, value):
	pass
#Note: when the enter or exit animation starts, it sets the character's controllable and invulnerable variables, make sure to set them back in the parent code






func _physics_process(_delta : float) -> void:
	if "\n" in destination_tag:
		destination_tag = destination_tag.replace("\n", "")
	if is_idle and enabled and !teleportation_mode:
		#the area2d is set to only collide with characters, so we can (hopefully) safely assume if there 
		#is a collision it's with a character
		for body in area2d.get_overlapping_bodies():
			if body.name.begins_with("Character") and !body.dead:
				body.toggle_movement(false)
				body.camera.set_zoom_tween(Vector2(1, 1), 0.5)
				start_pipe_enter_animation(body)
	var character
	for chr in stored_characters:
		if chr != null:
			character = chr
	#if character:
		#print(character.position)

func _on_body_entered(body):
	if enabled and is_idle and !entering and teleportation_mode:
		if body.name.begins_with("Character") and !body.dead:
			body.toggle_movement(false)
			body.camera.set_zoom_tween(Vector2(1, 1), 0.5)
			start_pipe_enter_animation(body)
				

func start_pipe_enter_animation(character : Character) -> void:
	stored_characters[character.player_id] = character
	is_idle = false
	entering = true
	

	if !teleportation_mode:
		var pair = find_local_pair()
		if pair.object_type == "area_transition":
			pair.is_idle = false
			character.gravity_scale = 0
			if character.player_id == 0:
				Singleton.CurrentLevelData.level_data.vars.transition_character_data = []
				Singleton.CurrentLevelData.level_data.vars.transition_character_data.append(AreaTransitionHelper.new(character.velocity, character.state, character.facing_direction, to_local(character.position), self.vertical))
			else:
				Singleton.CurrentLevelData.level_data.vars.transition_character_data_2 = []
				Singleton.CurrentLevelData.level_data.vars.transition_character_data_2.append(AreaTransitionHelper.new(character.velocity, character.state, character.facing_direction, to_local(character.position), self.vertical))
			character.camera.auto_move = false
	else:
		pass
	
	emit_signal("pipe_animation_finished", character, entering, force_fadeout)
	
	

func start_pipe_exit_animation(character : Character, tp_mode : bool) -> void:
	character.show()
	stored_characters[character.player_id] = character
	is_idle = false
	entering = false
	

	if !tp_mode:
		emit_signal("exit", character, entering, force_fadeout)
		
		# undo collision changes 
		character.set_collision_layer_bit(1, true)
		character.set_inter_player_collision(true) 
		character.gravity_scale = 1
		if get_character_transition_data(character).size() == 1:
			exit_with_helper(character)
		
	pipe_exit_anim_finished(character)
	reset_sprite(character)
	

func pipe_exit_anim_finished(character : Character):
	#this means we came from a transition 
	if (Singleton.CurrentLevelData.level_data.vars.transition_character_data.size() >= 7
	|| Singleton.CurrentLevelData.level_data.vars.transition_character_data_2.size() >= 7):
		exit_with_helper(character)
	# exits the pipe and gives back control to mario
	Singleton.CurrentLevelData.level_data.vars.transition_data = []
	Singleton.CurrentLevelData.level_data.vars.transition_character_data = []
	Singleton.CurrentLevelData.level_data.vars.transition_character_data_2 = []
	entering = false
	#character.toggle_movement(true)
	# undo collision changes 
	stored_characters[character.player_id] = null
	if !teleportation_mode:
		var timer = get_tree().create_timer(0.1)
		timer.connect("timeout", character, "toggle_movement", [true])
		timer.connect("timeout", self, "set_camera", [character])
	else:
		is_idle = true
		var timer = get_tree().create_timer(0.1)
		timer.connect("timeout", character, "toggle_movement", [true])
		timer.connect("timeout", self, "set_camera", [character])
	
func exit_with_helper(character : Character):
	var helper = get_character_transition_data(character).back()
	character.velocity = helper.velocity
	character.state = helper.state
	character.facing_direction = helper.facing_direction
	character.camera.global_position = helper.find_camera_position(vertical, character.global_position, character.camera.base_size, parts * 32)
	character.camera.last_position = character.camera.position
	character.position = global_position + helper.find_exit_offset(vertical, parts * 32)
	var timer = Timer.new()
	timer.connect("timeout", character, "toggle_movement", [true])
	timer.connect("timeout", self, "set_camera", [character])
	timer.wait_time = 0.1
	timer.one_shot = true
	add_child(timer)
	timer.start()
	if character.player_id == 0:
		Singleton.CurrentLevelData.level_data.vars.transition_character_data = []
	else:
		Singleton.CurrentLevelData.level_data.vars.transition_character_data_2 = []



func reset_sprite(character : Character): #This is here in case Mario came from a door to a pipe
	character.z_index = -1
	character.sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)
	character.sprite.scale = Vector2(1.0, 1.0)
	character.sprite.position = Vector2.ZERO
	character.sprite.reset_physics_interpolation()

func set_camera(character: Character):
	character.camera.auto_move = true
	character.call_deferred("set_collision_layer_bit", 1, true)
	character.set_inter_player_collision(true) 
	character.call_deferred("toggle_movement", true)


func get_character_transition_data(character : Character) -> Array:
		if character.player_id == 0:
			return Singleton.CurrentLevelData.level_data.vars.transition_character_data
		else:
			return Singleton.CurrentLevelData.level_data.vars.transition_character_data_2
			

func _process(delta):
	if parts <= 0:
		parts = 1
		set_property("parts", parts, true)
			
