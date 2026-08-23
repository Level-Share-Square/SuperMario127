extends BoxBase


const INITIAL_VEL: float = 150.0
const DEFAULT_SIZE := Vector2(32, 32)

onready var sprite = $"%Sprite"
onready var break_particles = $"%BreakParticles"

var coins: int = 0
var size := DEFAULT_SIZE


func _register_properties(): 
	register_property(4, "coins", coins, true)
	register_property(5, "size", size, true)


func _ready():
	var _connect = connect("property_changed", self, "update_property")
	update_property("size", size)


func update_property(key: String, value):
	if key == "size":
		sprite.rect_size = value
		sprite.rect_pivot_offset = sprite.rect_size / 2
		sprite.rect_position = -value / 2
		
		var scale_factor: Vector2 = sprite.rect_size / DEFAULT_SIZE
		break_particles.process_material = break_particles.process_material.duplicate()
		break_particles.process_material.initial_velocity = INITIAL_VEL * (scale_factor.x + scale_factor.y)/2
		
		box_collision.shape = box_collision.shape.duplicate()
		editor_collision.shape = box_collision.shape
		box_collision.shape.extents = value / 2
