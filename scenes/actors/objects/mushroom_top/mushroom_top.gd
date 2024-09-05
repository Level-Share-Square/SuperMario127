extends GameObject

export var custom_preview_position = Vector2(70, 170)
onready var collision_shape = $StaticBody2D/CollisionShape2D
onready var area_2d : Area2D = $StaticBody2D/Area2D
onready var animation_player : AnimationPlayer = $AnimationPlayer

var bounce_power = 300

var color := Color(1, 0, 0)
var bouncy := false
var strong_bounce_power := 750

var cooldown = 0.0
var idle_bounce_timer = 120 - rand_range(0, 110)

func _set_properties():
	savable_properties = ["color", "bouncy", "strong_bounce_power"]
	editable_properties = ["color", "bouncy", "strong_bounce_power"]
	
func _set_property_values():
	set_property("color", color, 1)
	set_property("bouncy", bouncy, 1)
	set_property("strong_bounce_power", strong_bounce_power, 1)

func _ready():
	collision_shape.disabled = !enabled
	preview_position = custom_preview_position
	if is_preview:
		z_index = 0
		$Sprite.z_index = 0

func _process(delta):
	if color == Color(1, 0, 0):
		$Sprite/Color.visible = false
	else:
		$Sprite/Color.visible = true
		$Sprite/Color.modulate = color
	
	if cooldown > 0:
		cooldown -= delta
		if cooldown <= 0:
			cooldown = 0
	
	if enabled and mode == 0 and bouncy == true:
		for body in area_2d.get_overlapping_bodies():
			bounce(body)
#		for area in area_2d.get_overlapping_areas():
#			if area.get_parent() is Character:
#				bounce(area)
		
		if idle_bounce_timer <= 0:
			if not animation_player.is_playing():
				animation_player.play("idle")
			idle_bounce_timer = 120
		
		idle_bounce_timer -= 1


func bounce(body):
	if cooldown != 0:
		return

	cooldown = 0.1
	var normal = transform.y
	
	if "velocity" in body:
		actually_bounce(body)
	elif "velocity" in body.get_parent():
		actually_bounce(body.get_parent())

func actually_bounce(body):
	var normal := transform.y
	var is_weak_bounce := true
	
	if "controllable" in body:
		if !body.controllable:
			return # Don't gbj players
	
	if body.has_method("set_state_by_name"):
		body.set_state_by_name("BounceState", 0)
		if body.inputs[2][0]:
			is_weak_bounce = false
			body.sound_player.play_double_jump_sound()
	animation_player.stop()
	
	var x_power = (-bounce_power if is_weak_bounce else -strong_bounce_power) * normal.x
	var y_power = (-bounce_power if is_weak_bounce else -strong_bounce_power) * normal.y
	
	if abs(normal.x) > 0.1:
		body.velocity.x = x_power
		# Test move to ensure the player doesn't end up inside of a tile
		if !body.has_method("test_move"):
			body.position.x += 2 * sign(x_power)
		elif !body.test_move(body.transform, Vector2(2 * sign(x_power), 0)):
			body.position.x += 2 * sign(x_power)
	if abs(normal.y) > 0.1:
		body.velocity.y = y_power
		# Test move to ensure the player doesn't end up inside of a tile
		if !body.has_method("test_move"):
			body.position.y += 2 * sign(y_power)
		elif !body.test_move(body.transform, Vector2(0, 2 * sign(y_power))):
			body.position.y += 2 * sign(y_power)
			# Bounce the player off of the ground if necessary,
			# if this wasn't done the player would stay on the ground, repeatedly bouncing
			if y_power < 0 and body.prev_is_grounded\
			and !body.test_move(body.transform, Vector2(0, 4 * sign(y_power))):
				body.position.y += 4 * sign(y_power)
	animation_player.play("bounce_weak" if is_weak_bounce else "bounce")
	
	if "stamina" in body:
		body.stamina = 100
