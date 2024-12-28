extends GameObject

onready var area_2d : Area2D = $Area2D
onready var bounce_fallback : Area2D = $FallbackBounce
onready var animation_player : AnimationPlayer = $AnimationPlayer
onready var sprite : NinePatchRect = $Visual/NinePatchRect
onready var note : Sprite = $Visual/NinePatchRect/Note
onready var sound : AudioStreamPlayer2D = $AudioStreamPlayer2D

onready var bounce_collision_shape : CollisionShape2D = $Area2D/CollisionShape2D
onready var bottom_collision_shape : CollisionShape2D = $StaticBody2D/CollisionShape2D
onready var platform_area_shape : CollisionShape2D = $StaticBody2D/Area2D/CollisionShape2D

onready var left_width = sprite.patch_margin_left
onready var right_width = sprite.patch_margin_right
onready var part_width = sprite.texture.get_width() - left_width - right_width

export var weak_bounce_sound : AudioStream
export var bounce_sound : AudioStream

var bounce_power = 300
var strong_bounce_power = 650
var blacklisted_bodies := {}

var parts := 1
var last_parts := 1


func _set_properties():
	savable_properties = ["parts", "strong_bounce_power"]
	editable_properties = ["parts", "strong_bounce_power"]
	
func _set_property_values():
	set_property("parts", parts, 1)
	set_property("strong_bounce_power", strong_bounce_power, 1)
	
func _ready():
	bounce_collision_shape.shape = bounce_collision_shape.shape.duplicate(true)
	bottom_collision_shape.shape = bottom_collision_shape.shape.duplicate(true)
	platform_area_shape.shape = platform_area_shape.shape.duplicate(true)
	
	if !enabled:
		bottom_collision_shape.disabled = true
		bounce_collision_shape.disabled = true
		platform_area_shape.disabled = true
	
	if enabled and mode == 0:
		area_2d.connect("body_entered", self, "bounce")
	elif mode == 1:
		var _connect = connect("property_changed", self, "update_property")
		
	update_parts()

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

func _physics_process(delta):
	for object in blacklisted_bodies.keys():
		var cooldown = blacklisted_bodies[object]
		if cooldown > 0:
			cooldown -= delta
			if cooldown <= 0:
				remove_body_to_bounce(object)
			else:
				blacklisted_bodies[object] = cooldown
		
	if enabled and mode == 0:
		if area_2d.get_overlapping_bodies().size() > 0:
			for body in area_2d.get_overlapping_bodies():
					bounce(body)

func bounce(body):
	if (body in blacklisted_bodies.keys()) == true:
		return
	
	var normal = transform.y
	
	if "velocity" in body:
		actually_bounce(body)
	elif "velocity" in body.get_parent():
		actually_bounce(body.get_parent())
	
	add_body_to_bounce(body)

func actually_bounce(body):
	var normal := transform.y
	var is_weak_bounce := true
	
	if "controllable" in body:
		if !body.controllable:
			return # Don't gbj players
	
	if body is Character:
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
			if y_power < 0 and body.is_on_floor() and !body.test_move(body.transform, Vector2(0, 4 * sign(y_power))):
				body.position.y += 4 * sign(y_power)
	animation_player.play("bounce_weak" if is_weak_bounce else "bounce")
	
	if "stamina" in body:
		body.stamina = 100

func update_property(key, value):
	match(key):
		"parts":
			update_parts()

func update_parts():
	sprite.rect_position.x = -(left_width + (part_width * parts) + right_width) / 2
	sprite.rect_size.x = left_width + right_width + part_width * parts

	bounce_collision_shape.shape.extents.x = (left_width + (part_width * parts) + right_width) / 2 + 1.5
	bottom_collision_shape.shape.extents.x = (left_width + (part_width * parts) + right_width) / 2 - 2
	platform_area_shape.shape.extents.x = (left_width + (part_width * parts) + right_width) / 2 + 20

	note.position.x = sprite.rect_size.x / 2

func add_body_to_bounce(body):
	blacklisted_bodies.get_or_add(body, 0.1)

func remove_body_to_bounce(body):
	blacklisted_bodies.erase(body)
