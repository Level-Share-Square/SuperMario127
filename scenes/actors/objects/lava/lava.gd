extends GameObject

var width := 600.0
var height := 300.0
var color := Color(1, 0, 0)
var render_in_front := false
var tag = "default"

var last_size : Vector2
var last_color : Color
var last_front : bool

var moving : bool = false
var match_level : float = 0.0
var move_speed : float = 1.0

onready var area_collision = $Area2D/CollisionShape2D
onready var body_collision = $StaticBody2D/CollisionShape2D
onready var sprite = $ColorRect
onready var waves = $TextureRect
onready var color_sprite = $TextureRect/Recolorable

func _set_properties():
	savable_properties = ["width", "height", "color", "render_in_front", "tag"]
	editable_properties = ["width", "height", "color", "render_in_front", "tag"]

func _set_property_values():
	set_property("width", width, true)
	set_property("height", height, true)
	set_property("color", color, true)
	set_property("render_in_front", render_in_front, true)
	set_property("tag", tag, true)
	
func _ready():
	area_collision.shape = area_collision.shape.duplicate()
	change_size()
	last_size = Vector2(width, height)

	area_collision.disabled = !enabled
	body_collision.disabled = !enabled
	
	CurrentLevelData.level_data.vars.liquids.append([tag.to_lower(), self])

func change_size():
	preview_position = Vector2(-width / 2, height / 2)
	sprite.rect_size = Vector2(width, height)
	waves.rect_size.x = sprite.rect_size.x
	color_sprite.rect_size.x = sprite.rect_size.x
	area_collision.position = Vector2(width / 2, height / 2)
	area_collision.shape.extents = area_collision.position
	
	body_collision.position = area_collision.position
	body_collision.shape = area_collision.shape
	
	var rounded_color = Color(stepify(color.r, 0.05), stepify(color.g, 0.05), stepify(color.b, 0.05))
	if rounded_color == Color(0.5, 0, 0) or rounded_color == Color(1, 0, 0):
		color_sprite.visible = false
		sprite.color = Color(0.431373, 0, 0.14902)
		sprite.modulate = Color(1, 1, 1)
		waves.self_modulate = Color(1, 1, 1)
	else:
		color_sprite.visible = true
		color_sprite.modulate = color
		sprite.color = Color(0.282353, 0.282353, 0.282353)
		sprite.modulate = color
		var desat_color = color
		desat_color.s /= 2
		waves.self_modulate = desat_color
	
	z_index = -1 if !render_in_front else 25
	#sprite.color = color

func _physics_process(delta):
	if !moving: return
	
	if global_position.y < match_level:
		global_position.y += move_speed
		if global_position.y >= match_level:
			moving = false
			global_position.y = match_level
	
	if global_position.y > match_level:
		global_position.y -= move_speed
		if global_position.y <= match_level:
			moving = false
			global_position.y = match_level

func _process(delta):
	if Vector2(width, height) != last_size:
		change_size()
	if color != last_color:
		change_size()
	if render_in_front != last_front:
		change_size()
	last_size = Vector2(width, height)
	last_color = color
	last_front = render_in_front
