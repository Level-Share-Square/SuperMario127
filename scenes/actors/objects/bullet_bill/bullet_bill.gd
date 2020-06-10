extends GameObject

onready var area = $Area2D
onready var stomp_detector = $StompDetector
onready var sprite = $Sprite
onready var sound = $AudioStreamPlayer
var collected = false
var character

var speed := 0.75
var chase := false

var update_timer = 0.0
var char_find_timer = 0.0

var cached_pos := Vector2()
var move_to := Vector2()

var dead = false
var velocity := Vector2()

func _set_properties():
	savable_properties = ["chase", "speed"]
	editable_properties = ["chase", "speed"]
	
func _set_property_values():
	set_property("chase", chase, true)
	set_property("speed", speed, true)

func kill(body):
	if enabled and body.name.begins_with("Character") and !body.dead and !dead and body.controllable:
		if !body.attacking and !body.invulnerable:
			body.velocity.x = (body.global_position - global_position).normalized().x * 205
			body.velocity.y = -175
			body.set_state_by_name("BonkedState", 0)
			body.damage()
		elif body.attacking:
			velocity = ((body.global_position - global_position).normalized() * -90)
			dead = true
			sound.play()
			
func detect_stomp(body):
	if enabled and body.name.begins_with("Character") and !body.dead and !dead:
		if body.velocity.y > 0:
			if body.state != body.get_state_node("GroundPoundState"):
				body.set_state_by_name("BounceState", 0)
				body.velocity.y = -330
			velocity.y = 60
			dead = true
			sound.play()

func _ready():
	if mode != 1:
		var _connect = area.connect("body_entered", self, "kill")
		var _connect2 = stomp_detector.connect("body_entered", self, "detect_stomp")

func _physics_process(delta):
	if cached_pos != Vector2() and character != null:
		move_to = move_to.linear_interpolate((cached_pos - global_position).normalized(), delta * 2)
		global_position += move_to * speed
		rotation = lerp_angle(rotation, (move_to.angle()), delta * 2)
		
	if mode != 1 and chase:
		if update_timer <= 0:
			if character != null:
				if !character.dead:
					cached_pos = character.global_position
			update_timer = 0.15
			
		if char_find_timer <= 0:
			var current_scene = get_tree().get_current_scene()
			var character_1 = current_scene.get_node(current_scene.character)
			
			if PlayerSettings.number_of_players == 1:
				character = character_1
			else:
				var character_2 = current_scene.get_node(current_scene.character2)
				var char1_distance = global_position.distance_to(character_1.global_position)
				var char2_distance = global_position.distance_to(character_2.global_position)
	
				if (char1_distance < char2_distance or character_2.dead) and !character_1.dead:
					character = character_1
				else:
					character = character_2
			cached_pos = character.global_position
			char_find_timer = 3.5
			
	if mode != 1:
		if dead:
			velocity.y += 5
			sprite.rotation_degrees += 2.5
			position += velocity * delta
		else:
			position.x += speed
			
	if char_find_timer > 0:
		char_find_timer -= delta
		if char_find_timer <= 0:
			char_find_timer = 0
			
	if update_timer > 0:
		update_timer -= delta
		if update_timer <= 0:
			update_timer = 0
