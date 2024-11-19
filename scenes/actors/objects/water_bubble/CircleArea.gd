tool
class_name CircleArea
extends Area2D

export(NodePath) var outer_path
export(NodePath) var fill_path

export var radius := 128 setget set_radius
export var vertex_cap := 128 setget set_vertex_cap
export var ready_update := true
export var dynamic_update := false

onready var outer = get_node(outer_path)
onready var fill = get_node(fill_path)
onready var collision = get_node("Shape")

func set_radius(value):
	radius = value
	update_circle()

func set_vertex_cap(value):
	vertex_cap = value
	update_circle()

func _ready():
	if ready_update:
		update_circle()

func _physics_process(delta):
	if dynamic_update:
		update_circle()


func update_circle():
	var wave_arr = get_circle_point_list(radius)
	var fill_arr = get_circle_point_list(radius, -16)
	
	if !is_instance_valid(outer):
		outer = get_node(outer_path)
		
	if !is_instance_valid(fill):
		fill = get_node(fill_path)
	
	outer.points = PoolVector2Array(wave_arr)
	
	var shader_scale : float = float(radius)/128.0
	outer.material.set_shader_param("scale", shader_scale)
	
	fill.polygon = PoolVector2Array(fill_arr)
	$"Shape".shape.radius = radius


func get_circle_point_list(rad : int, rad_offset = 0):
	var rad_final = rad+rad_offset
	var arr = []
	arr.resize(clamp(int(.3 * PI * rad_final) + 2, 0, vertex_cap))  # Point count = circle length / 200 + 2, tweak for different results
	var step = PI * 2 / (arr.size() - 1)
	
	for i in arr.size() - 1:
		arr[i] = Vector2(cos(step * i) * rad_final, sin(step * i) * rad_final)
	
	arr[arr.size() - 1] = Vector2(rad_final, 0)
	
	arr.append(arr[1])
	
	return arr
