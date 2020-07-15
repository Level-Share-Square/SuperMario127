extends GameObject

onready var area = $Area2D
onready var sprite = $Sprite
onready var particles = $Particles2D
onready var anim_player = $AnimationPlayer
onready var effects = $DemonEffects
var collected = false
var character

var chase := false
var chase_speed := 1.0

var update_timer = 0.0
var char_find_timer = 0.0

var cached_pos := Vector2()

func _set_properties():
	savable_properties = ["chase", "chase_speed"]
	editable_properties = ["chase", "chase_speed"]
	
func _set_property_values():
	set_property("chase", chase, true)
	set_property("chase_speed", chase_speed, true)

func kill(body):
	if enabled and body.name.begins_with("Character") and !body.dead and body.controllable:
		body.kill("green_demon")
		enabled = false
		chase = false
		sprite.visible = false
		particles.emitting = false
		effects.visible = false

func _ready():
	particles.process_material.scale = (scale.x + scale.y) / 2
	particles.amount = 6 * chase_speed
	if mode != 1:
		var _connect = area.connect("body_entered", self, "kill")

func _physics_process(delta):
	effects.rotation_degrees = (OS.get_ticks_msec()/16) % 360
	
	if cached_pos != Vector2() and chase and character != null:
		var move_to = (cached_pos - global_position).normalized()
		global_position += move_to * chase_speed
		
	if mode != 1 and chase:
		particles.emitting = true
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
	else:
		particles.emitting = false
			
	if char_find_timer > 0:
		char_find_timer -= delta
		if char_find_timer <= 0:
			char_find_timer = 0
			
	if update_timer > 0:
		update_timer -= delta
		if update_timer <= 0:
			update_timer = 0
