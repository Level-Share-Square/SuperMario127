extends GameObject

onready var area = $AttackArea
onready var area_collision_shape = $AttackArea/CollisionShape2D
onready var stomp_area = $StompArea
onready var sprite = $AnimatedSprite
onready var animation_player = $AnimationPlayer
onready var delete_timer = $DeleteTimer
onready var detect_area = $PlayerDetectArea
onready var undetect_area = $PlayerUndetectArea

onready var knockback_sound = $Knockback

var character : Character
var facing_direction := 1
var shy := false
var last_shy := false
var frame := 0.0
var dead

var middle_pos
var time_alive := 0.0
var sine_amplitude := 4.0
var sine_speed := 3.0
var follow_speed := 0.0

var speed := 1.0

var knockback_velocity : Vector2

func _set_properties():
	savable_properties = ["speed"]
	editable_properties = ["speed"]

func _set_property_values():
	set_property("speed", speed, true)

func is_vanish(body):
	if "Character" in body:
		return body.powerup != null and body.powerup.id == "Vanish"

func kill(body):
	if dead or !(enabled and body.name.begins_with("Character") and !body.dead and body.controllable):
		return
	
	if body.invincible:
		dead = true
		animation_player.play("die")
		return
	
	if !is_vanish(body):
		if !body.invulnerable and !body.attacking and !(abs((knockback_velocity.x + knockback_velocity.y) / 2) > 5):
			body.damage_with_knockback(global_position)
		if body.attacking:
			knockback_velocity.y = -80
			knockback(body.global_position)

func attacked(new_area):
	if !enabled: return

	if new_area.has_method("is_hurt_area"):
		knockback_velocity.y = -80
		knockback(area.global_position)

func stomp(body):
	if !enabled: return
	var body_cast = body as Character #this filters out any bodies other than the player from being used
	if "Character" in body:
		if body.invincible:
			dead = true
			animation_player.play("die")
			return
		elif is_vanish(body):
			return
		else:
			if body.velocity.y > 0:
				if body.state != body.get_state_node("GroundPoundState"):
					if body.state != body.get_state_node("DiveState"):
						body.set_state_by_name("BounceState", 0)
					body.velocity.y = -330
				body.stamina = clamp(body.stamina + 10, 0, 100)
				knockback_velocity.y = 80
				knockback(body.global_position)

func knockback(body_pos):
	knockback_sound.play()
	var direction = sign(body_pos.x - global_position.x)
	knockback_velocity.x = 100 * -direction

func detect_player(body):
	character = body

func undetect_player(body):
	if body == character:
		character = null

func _physics_process(delta):
	if !enabled: 
		sprite.frame = 3

	if mode == 1 or dead:
		return
	
	time_alive += delta * sine_speed
	global_position.y = middle_pos.y + sin(time_alive) * sine_amplitude
	global_position.x = middle_pos.x
	
	if !enabled:
		return
	
	var active_frame = 3
	
	if is_instance_valid(character):
		var direction = sign(character.global_position.x - global_position.x)
		facing_direction = direction
		
		shy = (facing_direction != character.facing_direction)
		if shy and abs((knockback_velocity.x + knockback_velocity.y) / 2) > 35:
			shy = false
		active_frame = 4
		middle_pos = middle_pos.move_toward(character.global_position, delta * follow_speed)
	else:
		shy = false
	
	if shy:
		frame = increment_towards(frame, 0, 0.5)
		sprite.self_modulate = lerp(sprite.self_modulate, Color(1, 1, 1, 0.5), delta * 8)
		sine_speed = lerp(sine_speed, 2.0, delta * 8)
		follow_speed = lerp(follow_speed, 0.0, delta * 8)
	else:
		var laugh_sound = get_tree().current_scene.get_node("SharedSounds").get_node("LaughSound")
		if last_shy and !laugh_sound.playing and randi() % 15 == 2:
			get_tree().current_scene.get_node("SharedSounds").PlaySound("LaughSound")
		
		frame = increment_towards(frame, active_frame, 0.5)
		sprite.self_modulate = lerp(sprite.self_modulate, Color(1, 1, 1, 1), delta * 8)
		sine_speed = lerp(sine_speed, 3.0, delta * 8)
		follow_speed = lerp(follow_speed, 27.5 * speed, delta * 8)
	
	sprite.frame = frame
	sprite.flip_h = (facing_direction != 1)
	
	last_shy = shy

	knockback_velocity = lerp(knockback_velocity, Vector2(), delta * 2)
	middle_pos += knockback_velocity * delta

func _ready():
	var _connect = area.connect("body_entered", self, "kill")
	_connect = area.connect("area_entered", self, "attacked")
	_connect = stomp_area.connect("body_entered", self, "stomp")
	_connect = delete_timer.connect("timeout", self, "queue_free")
	_connect = detect_area.connect("body_entered", self, "detect_player")
	_connect = undetect_area.connect("body_exited", self, "undetect_player")
	middle_pos = global_position
	
	if mode != 1 and scale.x < 0:
		scale.x = abs(scale.x)
		facing_direction = -1
		sprite.flip_h = true

func increment_towards(value, target, step):
	if value > target:
		value -= step
		if value <= target:
			value = target
	
	if value < target:
		value += step
		if value >= target:
			value = target
	
	return value
