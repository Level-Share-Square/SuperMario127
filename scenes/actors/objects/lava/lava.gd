extends GameObject

var width := 600.0
var height := 300.0
var color := Color(0.513726, 0, 0)

var last_size : Vector2
var last_color : Color

onready var area_collision = $Area2D/CollisionShape2D
onready var sprite = $ColorRect

func _set_properties():
	savable_properties = ["width", "height", "color"]
	editable_properties = ["width", "height", "color"]

func _set_property_values():
	set_property("width", width, true)
	set_property("height", height, true)
	set_property("color", color, true)
	
func _ready():
	area_collision.shape = area_collision.shape.duplicate()
	change_size()
	last_size = Vector2(width, height)

func change_size():
	preview_position = Vector2(-width / 2, height / 2)
	sprite.rect_size = Vector2(width, height)
	sprite.color = color
	area_collision.position = Vector2(width / 2, height / 2)
	area_collision.shape.extents = area_collision.position

func _process(delta):
	if Vector2(width, height) != last_size:
		change_size()
	if color != last_color:
		change_size()
	last_size = Vector2(width, height)
	last_color = color
