extends GameObject

const SINKING_FORCE : Vector2 = Vector2(0, 10)

export(Array, Texture) var palette_textures

onready var sprite = $BuoyancyController/Sprite
onready var static_body = $BuoyancyController/StaticBody2D
onready var platform_area = $BuoyancyController/StaticBody2D/Area2D
onready var platform_area_collision_shape = $BuoyancyController/StaticBody2D/Area2D/CollisionShape2D
onready var collision_shape = $BuoyancyController/StaticBody2D/CollisionShape2D
onready var buoyancy_controller = $"%BuoyancyController"


var parts : int = 1

var physics_enabled := true
var spawn_pos : Vector2 = Vector2(0, 0)

#func _set_properties():
#	savable_properties = ["parts", "physics_enabled"]
#	editable_properties = ["parts", "physics_enabled"]
	
func _register_properties():
	register_property(5, "physics_enabled", physics_enabled, true)

func _unhandled_input(event: InputEvent) -> void:
	parts_input_handler(event,self)
	
func _ready():
	if palette != 0:
		sprite.texture = palette_textures[palette]
	
	spawn_pos = global_position
	
	if !is_enabled_and_on_ground():
		collision_shape.disabled = true
	
	buoyancy_controller.can_sink = true
	buoyancy_controller.init_physics()
	buoyancy_controller.standing_detector_shape.shape.extents.x = collision_shape.shape.extents.x
	buoyancy_controller.standing_detector.position.y = static_body.position.y + buoyancy_controller.standing_detector_shape.shape.extents.y
func _physics_process(delta):
	static_body.constant_linear_velocity = buoyancy_controller.linear_velocity

	
func apply_sinking_force():
	buoyancy_controller.add_force(Vector2.ZERO, SINKING_FORCE)
