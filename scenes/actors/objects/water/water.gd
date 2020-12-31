extends GameObject

var width := 600.0
var height := 300.0
var last_size : Vector2

onready var area_collision = $Area2D/CollisionShape2D
onready var sprite = $ColorRect
onready var waves = $Waves

func _set_properties():
	savable_properties = ["width", "height"]
	editable_properties = ["width", "height"]

func _set_property_values():
	set_property("width", width, true)
	set_property("height", height, true)
	
func _ready():
	area_collision.shape = area_collision.shape.duplicate()
	change_size()
	last_size = Vector2(width, height)

func change_size():
	preview_position = Vector2(-width / 2, -height / 2)
	sprite.rect_size = Vector2(width, height)
	area_collision.position = Vector2(width / 2, height / 2)
	area_collision.shape.extents = area_collision.position
	
	waves.rect_size.x = width
	waves.material = waves.get_material().duplicate()
	waves.get_material().set_shader_param("x_size", width)

func _process(delta):
	if Vector2(width, height) != last_size:
		change_size()
	last_size = Vector2(width, height)
