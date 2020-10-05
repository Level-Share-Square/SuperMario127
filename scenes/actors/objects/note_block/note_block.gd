extends GameObject

onready var area_2d : Area2D = $Area2D
onready var animation_player : AnimationPlayer = $AnimationPlayer
onready var sprite : NinePatchRect = $Visual/NinePatchRect
onready var note : Sprite = $Visual/NinePatchRect/Note

onready var bounce_collision_shape : CollisionShape2D = $Area2D/CollisionShape2D
onready var bottom_collision_shape : CollisionShape2D = $StaticBody2D/CollisionShape2D

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
	bottom_collision_shape.shape = bottom_collision_shape.shape.duplicate(true)
	
	if !enabled:
		bottom_collision_shape.disabled = true
		bounce_collision_shape.disabled = true
		
	update_parts()
	area_2d.connect("body_entered", self, "bounce")

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

func bounce(body):
	if "velocity" in body:
		var is_weak_bounce = true
		if body.has_method("set_state_by_name"):
			body.set_state_by_name("BounceState", 0)
			if body.inputs[2][0]:
				is_weak_bounce = false
				body.sound_player.play_double_jump_sound()
				
		animation_player.stop()
		body.velocity.y = -bounce_power if is_weak_bounce else -strong_bounce_power
		body.position.y -= 2
		animation_player.play("bounce_weak" if is_weak_bounce else "bounce")
	elif "velocity" in body.get_parent():
		animation_player.stop()
		body.get_parent().velocity.y = -bounce_power
		body.get_parent().position.y -= 2
		animation_player.play("bounce_weak")

func update_parts():
	sprite.rect_position.x = -(left_width + (part_width * parts) + right_width) / 2
	sprite.rect_size.x = left_width + right_width + part_width * parts

	bounce_collision_shape.shape.extents.x = (left_width + (part_width * parts) + right_width) / 2 + 1.5
	bottom_collision_shape.shape.extents.x = (left_width + (part_width * parts) + right_width) / 2 - 1

	note.position.x = sprite.rect_size.x / 2
