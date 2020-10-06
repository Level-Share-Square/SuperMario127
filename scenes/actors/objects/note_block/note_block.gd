extends GameObject

onready var area_2d : Area2D = $Area2D
onready var animation_player : AnimationPlayer = $AnimationPlayer
onready var sprite : NinePatchRect = $Visual/NinePatchRect
onready var note : Sprite = $Visual/NinePatchRect/Note

onready var bounce_collision_shape : CollisionShape2D = $Area2D/CollisionShape2D
#onready var bottom_collision_shape : CollisionShape2D = $StaticBody2D/CollisionShape2D

onready var left_width = sprite.patch_margin_left
onready var right_width = sprite.patch_margin_right
onready var part_width = sprite.texture.get_width() - left_width - right_width

var bounce_power = 300
var strong_bounce_power = 650

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
	#bottom_collision_shape.shape = bottom_collision_shape.shape.duplicate(true)
	
	if !enabled:
		#bottom_collision_shape.disabled = true
		bounce_collision_shape.disabled = true
		
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

func _process(_delta):
	if parts != last_parts:
		update_parts()
	last_parts = parts
	
	if enabled and mode == 0:
		for body in area_2d.get_overlapping_bodies():
			bounce(body)

func bounce(body):
	var normal = transform.y
	
	if "velocity" in body:
		if (normal.y < -0.1 and body.velocity.y > 0) or (normal.y > 0.1 and body.velocity.y < 0):
			return
		if (normal.x < -0.1 and body.velocity.x > 0) or (normal.x > 0.1 and body.velocity.x < 0):
			return
		
		var is_weak_bounce = true
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
			body.position.x += 2 * sign(x_power)
		if abs(normal.y) > 0.1:
			body.velocity.y = y_power
			body.position.y += 2 * sign(y_power)
		animation_player.play("bounce_weak" if is_weak_bounce else "bounce")
	elif "velocity" in body.get_parent():
		var body_parent = body.get_parent()
		if (normal.y < -0.1 and body_parent.velocity.y > 0) or (normal.y > 0.1 and body_parent.velocity.y < 0):
			return
		if (normal.x < -0.1 and body_parent.velocity.x > 0) or (normal.x > 0.1 and body_parent.velocity.x < 0):
			return
		
		animation_player.stop()
		
		var x_power = (-bounce_power) * normal.x
		var y_power = (-bounce_power) * normal.y
		
		if abs(normal.x) > 0.1:
			body_parent.velocity.x = x_power
			body_parent.position.x += 2 * sign(x_power)
		if abs(normal.y) > 0.1:
			body_parent.velocity.y = y_power
			body_parent.position.y += 2 * sign(y_power)
		animation_player.play("bounce_weak")

func update_parts():
	sprite.rect_position.x = -(left_width + (part_width * parts) + right_width) / 2
	sprite.rect_size.x = left_width + right_width + part_width * parts

	bounce_collision_shape.shape.extents.x = (left_width + (part_width * parts) + right_width) / 2 + 1.5
	#bottom_collision_shape.shape.extents.x = (left_width + (part_width * parts) + right_width) / 2 - 1

	note.position.x = sprite.rect_size.x / 2
