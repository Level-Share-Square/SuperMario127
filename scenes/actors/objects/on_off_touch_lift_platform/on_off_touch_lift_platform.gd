extends SemiSolidPlatform

export (Array, Texture) var palette_texture = []

onready var sprite = $Sprite
onready var sprite2 = $Sprite2
onready var animation_player = $AnimationPlayer

onready var area_2d = $Area2D
onready var platform_area_collision_shape = $Area2D/CollisionShape2D
onready var collision_shape = $CollisionShape2D

onready var left_width = sprite.patch_margin_left
onready var right_width = sprite.patch_margin_right
onready var part_width = 6

onready var inverted :bool= get_parent().inverted

onready var parent = get_parent()

var cancel_momentum: bool = false
var apply_velocity: bool = false
var last_position: Vector2
var momentum: Vector2

func set_position(new_position):
	if(parent.frozen == true):
		return
	# Calculate intended motion
	movement = get_parent().to_global(new_position) - global_position
	
	# Move to position
	position = new_position

func set_parts(parts: int):
	sprite.rect_position.x = -(left_width + (part_width * parts) + right_width) / 2
	sprite.rect_size.x = left_width + right_width + part_width * parts
	sprite.rect_pivot_offset = sprite.rect_size/2

	sprite2.rect_position.x = sprite.rect_position.x

	sprite2.rect_size.x = sprite.rect_size.x

	sprite2.rect_pivot_offset = sprite2.rect_size/2

	platform_area_collision_shape.shape.extents.x = (left_width + (part_width * parts) + right_width) / 2
	collision_shape.shape.extents.x = (left_width + (part_width * parts) + right_width) / 2

func _ready():
	parent = get_parent()

	sprite.region_rect.position.y = int(parent.palette) * 13

	sprite.region_rect.position.x = int(!parent.disappears) * 46


	sprite2.region_rect.position.y = sprite.region_rect.position.y
	sprite2.region_rect.position.x = 23 + int(!parent.disappears) * 46

	collision_shape.shape = collision_shape.shape.duplicate()
	platform_area_collision_shape.shape = platform_area_collision_shape.shape.duplicate()

	inverted = parent.inverted
	
	switch_state(inverted)

	if Singleton.CurrentLevelData.level_data.vars.switch_state.has(parent.palette):
		toggle_state()

	Singleton.CurrentLevelData.level_data.vars.connect("switch_state_changed", self, "_on_switch_state_changed")

	_on_switch_state_changed(parent.palette)

	#parent._ready()
	#parent._set_platform_pos()
	last_position = global_position
	collision_shape.shape = collision_shape.shape.duplicate()
	platform_area_collision_shape.shape = platform_area_collision_shape.shape.duplicate()


func _physics_process(delta):
	if(parent.frozen == true):
		return
	
	momentum = (global_position - last_position) / (fps_util.PHYSICS_DELTA * 3)
	last_position = global_position
	
	sprite.region_rect.position.x = int(!parent.disappears) * 46

	sprite2.region_rect.position.x = 23 + int(!parent.disappears) * 46


func toggle_state():
	inverted = !inverted
	switch_state(inverted)

func switch_state(new_state):
		if(parent.disappears):
			set_collision_layer_bit(4, new_state)
			platform_area_collision_shape.disabled = !new_state
			animation_player.play(str(new_state).to_lower())
			sprite.visible = new_state
			sprite2.visible = !new_state
		else:
			sprite.visible = true
			parent.frozen = !new_state
			sprite2.region_rect.position.x = 69 + int(!new_state) * 23

func _on_switch_state_changed(channel):
	if channel == parent.palette:
		toggle_state()


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
