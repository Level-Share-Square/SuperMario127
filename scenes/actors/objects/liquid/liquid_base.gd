class_name LiquidBase
extends GameObject

enum LiquidType {Water, Lava, Quicksand, Poison}

export (LiquidType) var liquid_type
export var size := Vector2(640.0, 320.0)
export var color := Color(0.19, 0.52, 1)
export var render_in_front := false
export var tag = "default"
export var waves_enable : bool = true

var crystal_tap_mode : bool = true
var moving : bool = false
var move_speed : float = 1.0
var horizontal : bool = false
var last_size : Vector2
var last_color : Color
var last_front : bool
var match_level : float = 0.0
var save_pos : Vector2

export var surface_offset : float = 0.0

onready var liquid_area : Area2D = $LiquidArea

onready var liquid_area_collision : CollisionShape2D = $LiquidArea/CollisionShape2D

onready var visual : Node2D = $Visual

onready var liquid_body : Control = $Visual/Body

onready var waves : Control = $Visual/Waves

var liquid_properties: Array = [
	"size",
	"color",
	"render_in_front",
	"tag",
	"crystal_tap_mode",
	"waves_enable",
]

signal transform_changed()


func get_liquid_properties() -> Array:
	return []


func set_liquid_property_menus():
	pass


func update_liquid_color(color : Color):
	pass


func update():
	pass


func update_property(key, value):
	pass


#func _set_properties():
#	savable_properties = []
#	editable_properties = []
#	for liquid_property in liquid_properties:
#		savable_properties.append(liquid_property)
#		editable_properties.append(liquid_property)
#
#	#extra liquid properties that a liquid might have
#	var i: int = 0
#	for liquid_property in get_liquid_properties():
#		savable_properties.append(liquid_property)
#		editable_properties.insert(i, liquid_property)
#		i += 1


func _register_properties():
	var id: int = 4
	for liquid_property in liquid_properties:
		register_property(id, liquid_property, self[liquid_property])
		id += 1
	set_property_override("crystal_tap_mode", PropertyTab.OverrideTypes.BOOL_ALIAS, {true: "Move", false: "Grow/Shrink"})
	
	for liquid_property in get_liquid_properties():
		register_property(id, liquid_property, self[liquid_property])
		id += 1
	set_liquid_property_menus()


func _object_ready():
	connect("transform_changed", self, "update")
	connect("ready", self, "change_size")
	
	var id = CurrentLevelData.vars.current_liquid_id
	if CurrentLevelData.vars.liquid_positions.size() > CurrentLevelData.area_id and CurrentLevelData.vars.liquid_positions[CurrentLevelData.area_id].size() > id:
		var set_position = CurrentLevelData.vars.liquid_positions[CurrentLevelData.area_id][id]
		if set_position != Vector2():
			global_position = set_position
			save_pos = set_position
	CurrentLevelData.vars.current_liquid_id += 1
	
	last_size = size
	
	liquid_area.monitoring = (is_enabled_and_on_ground() and mode != 1)
	liquid_area.monitorable = (is_enabled_and_on_ground() and mode != 1)
	
	CurrentLevelData.vars.liquids.append([tag.to_lower(), self])


func _editor_ready() -> void:
	connect("property_changed", self, "update_property")
	_object_ready()


func change_size():
	if !is_instance_valid(waves) and !is_instance_valid(liquid_body): return
	
	preview_position = -size/2
	liquid_area_collision.position = size/2
	liquid_area_collision.shape.extents = liquid_area_collision.position
	
	last_size = size
	last_color = color
	last_front = render_in_front
	emit_signal("transform_changed") #calling update in here causes issues with getting nodes, so we connect that to this instead


func _object_physics_process(_delta):
	if !moving: return
	
	if !horizontal:
		var end_pos := global_position.y + size.y
		var speed_modifier : float = transform.basis_xform(Vector2(0.0, 1.0)).y
		global_position.y = move_toward(global_position.y, match_level, move_speed * 2)
		if global_position.y == match_level:
			moving = false
			return
		if !crystal_tap_mode:
			size.y += speed_modifier * ((end_pos - global_position.y) - size.y)
			change_size() # Letting it happen in _process causes issues
	else:
		var end_pos := global_position.x + size.x
		if global_position.x == end_pos:
			moving = false
			return
		var speed_modifier : float = transform.basis_xform(Vector2(0.0, 1.0)).x
		global_position.x = move_toward(global_position.x, match_level, move_speed * 2)
		if global_position.x == match_level:
			moving = false
			return
		if !crystal_tap_mode:
			size.y += speed_modifier * ((end_pos - global_position.x) - size.y)
			change_size() # Letting it happen in _process causes issues


func _object_process(_delta):
	if "\n" in tag:
		tag = tag.replace("\n", "")
	if (size != last_size ||
			color != last_color ||
			render_in_front != last_front):
		change_size()
	if waves_enable != waves.visible:
		waves.visible = waves_enable
