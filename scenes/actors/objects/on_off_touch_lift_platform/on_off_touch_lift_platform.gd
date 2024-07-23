extends SemiSolidPlatform

export (Array, Texture) var palette_texture = []

onready var sprite = $Sprite
onready var sprite2 = $Sprite2
onready var animation_player = $AnimationPlayer

onready var platform_area_collision_shape = $Area2D/CollisionShape2D
onready var collision_shape = $CollisionShape2D

onready var left_width = sprite.patch_margin_left
onready var right_width = sprite.patch_margin_right
onready var part_width = 6

onready var inverted :bool= get_parent().inverted

onready var parent = get_parent()

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



func _physics_process(delta):
	if(parent.frozen == true):
		return

	sprite.region_rect.position.x = int(!parent.disappears) * 46

	sprite2.region_rect.position.x = 23 + int(!parent.disappears) * 46


func toggle_state():
	inverted = !inverted
	switch_state(inverted)

func switch_state(new_state):
		if(parent.disappears):
			set_collision_layer_bit(4, new_state)
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
