extends GameObject

var width := 600.0
var height := 300.0
var color := Color(0.19, 0.52, 1)
var render_in_front := false
var tag = "default"

var last_size : Vector2
var last_color : Color
var last_front : bool

var moving : bool = false
var match_level : float = 0.0
var move_speed : float = 1.0

var save_pos : Vector2

onready var area_collision = $Area2D/CollisionShape2D
onready var sprite = $ColorRect
onready var waves = $Waves

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
	var id = CurrentLevelData.level_data.vars.current_liquid_id
	if CheckpointSaved.current_checkpoint_id != -1 and CheckpointSaved.liquid_positions[CurrentLevelData.area].size() >= id:
		var set_position = CheckpointSaved.liquid_positions[CurrentLevelData.area][id]
		if set_position != Vector2():
			global_position = set_position
	CurrentLevelData.level_data.vars.current_liquid_id += 1
	
	color.a = 0.5
	area_collision.shape = area_collision.shape.duplicate()
	change_size()
	last_size = Vector2(width, height)
	
	area_collision.disabled = !enabled
	
	CurrentLevelData.level_data.vars.liquids.append([tag.to_lower(), self])

func change_size():
	preview_position = Vector2(-width / 2, -height / 2)
	sprite.rect_size = Vector2(width, height)
	sprite.material = sprite.get_material().duplicate()
	sprite.get_material().set_shader_param("color_tint", color)
	area_collision.position = Vector2(width / 2, height / 2)
	area_collision.shape.extents = area_collision.position
	
	waves.rect_size.x = width
	waves.material = waves.get_material().duplicate()
	waves.get_material().set_shader_param("color_tint", color)
	waves.get_material().set_shader_param("x_size", width)
	
	z_index = -1 if !render_in_front else 25

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
