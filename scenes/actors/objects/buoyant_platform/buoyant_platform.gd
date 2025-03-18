extends GameObject


#-------------------------------- GameObject logic -----------------------


export(Array, Texture) var palette_textures


export var parts := 1
var last_parts := 1

var physics_enabled := true

func _set_properties():
	savable_properties = ["parts", "physics_enabled"]
	editable_properties = ["parts", "physics_enabled"]
	
func _set_property_values():
	set_property("parts", parts, 1)
	set_property("physics_enabled", physics_enabled)

func _input(event):
	parts_input_handler(event,self)

func _process(_delta):
	if parts != last_parts:
		update_parts()
	last_parts = parts


#---------------------------- buoyancy logic ---------------------




#-------------------------------- platform logic -----------------------
	
onready var sprite = $RigidBody2D/Sprite
onready var static_body = $RigidBody2D/StaticBody2D
onready var platform_area = $RigidBody2D/StaticBody2D/Area2D
onready var platform_area_collision_shape = $RigidBody2D/StaticBody2D/Area2D/CollisionShape2D
onready var collision_shape = $RigidBody2D/StaticBody2D/CollisionShape2D
onready var rigidbody = $RigidBody2D

onready var left_width = sprite.patch_margin_left
onready var right_width = sprite.patch_margin_right
onready var part_width = sprite.texture.get_width() - left_width - right_width

var scale_x : float
export var override_part_width := 0 # If this value is not equal to 0, this'll replace part_width with it's value
var spawn_pos

func _ready():
	if palette != 0:
		$Sprite.texture = palette_textures[palette]

	if override_part_width != 0:
		part_width = override_part_width

	platform_area_collision_shape.shape = platform_area_collision_shape.shape.duplicate(true)
	collision_shape.shape = collision_shape.shape.duplicate(true)
	
	spawn_pos = global_position
	
	if !enabled:
		collision_shape.disabled = true
		
	update_parts()

func _physics_process(delta):
	static_body.constant_linear_velocity = rigidbody.linear_velocity
	reset_physics_interpolation()

func platform_area_entered(area):
	if area.get_parent().name.begins_with("DeathPlane"):
		global_position = spawn_pos
		rotation_degrees = 0
		

func update_parts():
	sprite.rect_position.x = -(left_width + (part_width * parts) + right_width) / 2
	sprite.rect_size.x = left_width + right_width + part_width * parts

	platform_area_collision_shape.shape.extents.x = (left_width + (part_width * parts) + right_width) / 2 + 20
	collision_shape.shape.extents.x = (left_width + (part_width * parts) + right_width) / 2
	rigidbody.shape.extents.x = collision_shape.shape.extents.x
	#calculate the total platform scale
	scale_x = scale.x * (left_width + right_width + part_width * parts) / (left_width + right_width + part_width)
