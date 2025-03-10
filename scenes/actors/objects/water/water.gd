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
var horizontal : bool = false
var match_level : float = 0.0
var move_speed : float = 1.0
var toxicity : float = 0.0
var tap_mode : bool = true

var save_pos : Vector2

onready var area = $Col
onready var area_collision = $Col/CollisionShape2D
onready var sprite = $ColorRect
onready var waves = $Waves

func _set_properties():
	savable_properties = ["width", "height", "color", "render_in_front", "tag", "toxicity", "tap_mode"]
	editable_properties = ["width", "height", "color", "render_in_front", "tag", "toxicity", "tap_mode"]

func _set_property_values():
	set_property("width", width, true)
	set_property("height", height, true)
	set_property("color", color, true)
	set_property("render_in_front", render_in_front, true)
	set_property("tag", tag, true)
	set_property("toxicity", toxicity, true)
	set_property("tap_mode", tap_mode, true)
	set_bool_alias("tap_mode", "Move", "Scale")

func _ready():
	var id = Singleton.CurrentLevelData.level_data.vars.current_liquid_id
	if Singleton.CurrentLevelData.level_data.vars.liquid_positions.size() > Singleton.CurrentLevelData.area and Singleton.CurrentLevelData.level_data.vars.liquid_positions[Singleton.CurrentLevelData.area].size() > id:
		var set_position = Singleton.CurrentLevelData.level_data.vars.liquid_positions[Singleton.CurrentLevelData.area][id]
		if set_position != Vector2():
			global_position = set_position
			save_pos = set_position
	Singleton.CurrentLevelData.level_data.vars.current_liquid_id += 1
	
	color.a = 0.5
	area_collision.shape = area_collision.shape.duplicate()
	change_size()
	last_size = Vector2(width, height)
	
	area_collision.disabled = !enabled
	
	Singleton.CurrentLevelData.level_data.vars.liquids.append([tag.to_lower(), self])

func change_size():
	preview_position = Vector2(-width / 2, -height / 2)
	sprite.rect_size = Vector2(width, height - 15)
	sprite.material = sprite.get_material().duplicate()
	sprite.get_material().set_shader_param("color_tint", color)
	area_collision.position = Vector2(width / 2, height / 2)
	area_collision.shape.extents = area_collision.position
	
	waves.rect_size.x = width
	waves.material = waves.get_material().duplicate()
	waves.get_material().set_shader_param("color_tint", color)
	waves.get_material().set_shader_param("x_size", width)
	
	z_index = -1 if !render_in_front else 25
	
	last_size = Vector2(width, height)
	last_color = color
	last_front = render_in_front

func _physics_process(_delta):
	if !moving: return
	
	if !horizontal:
		var end_pos := global_position.y + height
		var speed_modifier : float = transform.basis_xform(Vector2(0.0, 1.0)).y
		global_position.y = move_toward(global_position.y, match_level, move_speed * 2)
		if global_position.y == match_level:
			moving = false
			return
		if !tap_mode:
			height += speed_modifier * ((end_pos - global_position.y) - height)
			change_size() # Letting it happen in _process causes issues
	else:
		var end_pos := global_position.x + height
		if global_position.x == end_pos:
			moving = false
			return
		var speed_modifier : float = transform.basis_xform(Vector2(0.0, 1.0)).x
		global_position.x = move_toward(global_position.x, match_level, move_speed * 2)
		if global_position.x == match_level:
			moving = false
			return
		if !tap_mode:
			height += speed_modifier * ((end_pos - global_position.x) - height)
			change_size() # Letting it happen in _process causes issues

func _process(_delta):
	if "\n" in tag:
		tag = tag.replace("\n", "")
	if (Vector2(width, height) != last_size ||
			color != last_color ||
			render_in_front != last_front):
		change_size()
