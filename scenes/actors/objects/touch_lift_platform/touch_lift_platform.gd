extends SemiSolidPlatform

onready var sprite = $Sprite
onready var recolor_sprite = $SpriteRecolor

onready var platform_area_collision_shape = $Area2D/CollisionShape2D
onready var collision_shape = $CollisionShape2D

onready var left_width = sprite.patch_margin_left
onready var right_width = sprite.patch_margin_right
onready var part_width = sprite.texture.get_width() - left_width - right_width


var last_position : Vector2

var cancel_momentum: bool = false
var momentum : Vector2

var apply_velocity = false

func set_position(new_position):
	# Calculate intended motion
	movement = get_parent().to_global(new_position) - global_position
	
	# Move to position
	position = new_position
	reset_physics_interpolation()


func set_parts(parts: int):
	sprite.rect_position.x = -(left_width + (part_width * parts) + right_width) / 2
	sprite.rect_size.x = left_width + right_width + part_width * parts
	
	recolor_sprite.rect_position.x = -(left_width + (part_width * parts) + right_width) / 2
	recolor_sprite.rect_size.x = left_width + right_width + part_width * parts
	
	platform_area_collision_shape.shape.extents.x = (left_width + (part_width * parts) + right_width) / 2
	collision_shape.shape.extents.x = (left_width + (part_width * parts) + right_width) / 2


func _ready():
	last_position = global_position
	collision_shape.shape = collision_shape.shape.duplicate()
	platform_area_collision_shape.shape = platform_area_collision_shape.shape.duplicate()


func _physics_process(delta):
	momentum = (global_position - last_position) / (fps_util.PHYSICS_DELTA * 3)
	last_position = global_position


# this is to fix the wile coyote bug
func _on_Area2D_body_exited(body):
	if cancel_momentum:
		cancel_momentum = false
		return
	if body.get("velocity") != null and apply_velocity:
		body.velocity += Vector2(momentum.x, min(0, momentum.y))
		apply_velocity = false
	if "state" in body and !is_instance_valid(body.state):
		body.set_state_by_name("FallState")
		#self.apply_velocity = false
