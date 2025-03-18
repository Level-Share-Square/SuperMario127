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
	if event is InputEventMouseButton and event.is_pressed() and hovered:
		if event.button_index == 5: # Mouse wheel down
			parts -= 1
			if parts < 1:
				parts = 1
			set_property("parts", parts, true)
		elif event.button_index == 4: # Mouse wheel up
			parts += 1
			set_property("parts", parts, true)

func _process(_delta):
	if parts != last_parts:
		update_parts()
	last_parts = parts


#---------------------------- buoyancy logic ---------------------




#-------------------------------- platform logic -----------------------
	
onready var sprite = $RigidBody2D/Sprite
onready var platform_area = $RigidBody2D/StaticBody2D/Area2D
onready var platform_area_collision_shape = $RigidBody2D/StaticBody2D/Area2D/CollisionShape2D
onready var collision_shape = $RigidBody2D/StaticBody2D/CollisionShape2D
onready var rigidbody = $RigidBody2D
onready var rigidbody_shape = $RigidBody2D/CollisionShape2D

onready var left_width = sprite.patch_margin_left
onready var right_width = sprite.patch_margin_right
onready var part_width = sprite.texture.get_width() - left_width - right_width

var scale_x : float
export var override_part_width := 0 # If this value is not equal to 0, this'll replace part_width with it's value

var can_collide_with_floor = false

onready var animplay = $AnimationPlayer

# initialize parameters for query
onready var waterdet = $watercol
onready var grounddet = $groundcol
onready var topdet = $topcol
var water = null
var water_array : Array
var grav
var buoyancy = 0.1
var spawn_pos = Vector2(0,0)

var buoyancy_point:= preload("res://scenes/actors/objects/buoyant_platform/BuoyancyPoint.tscn")
var point_area : Area2D

var in_water = false

func _ready():
	if palette != 0:
		$Sprite.texture = palette_textures[palette]
	
	#print(grav)
	if physics_enabled:

		var _connect4 = platform_area.connect("area_entered", self, "platform_area_entered")
	if override_part_width != 0:
		part_width = override_part_width

	platform_area_collision_shape.shape = platform_area_collision_shape.shape.duplicate(true)
	collision_shape.shape = collision_shape.shape.duplicate(true)
	
	spawn_pos = global_position
	
	if !enabled:
		collision_shape.disabled = true
		
	update_parts()
	point_area = buoyancy_point.instance()
	rigidbody.add_child(point_area)
	point_area.global_position = rigidbody.global_position
	point_area.add_collision_shapes(rigidbody_shape.shape.extents.x * 2)
	point_area.connect("area_shape_entered", self, "buoyancy_point_submerged")
	point_area.connect("area_shape_exited", self, "buoyancy_point_surfaced")
	

func platform_area_entered(area):
	if area.get_parent().name.begins_with("DeathPlane"):
		global_position = spawn_pos
		rotation_degrees = 0
		
func buoyancy_point_submerged(area_rid: RID, area: Area, area_shape_index: int, local_shape_index: int):

	var local_shape_owner = point_area.shape_find_owner(local_shape_index)
	var local_shape_node = point_area.shape_owner_get_owner(local_shape_owner)
	var dif = local_shape_node.global_position - rigidbody.global_position
	dif = local_shape_node.position
	rigidbody.add_force(dif, Vector2(0, -98))
	dif = local_shape_node.global_position - rigidbody.global_position
	rigidbody.linear_velocity += Vector2(rigidbody.rotation_degrees/90 * abs(dif.x), 0)
	pass
	
func buoyancy_point_surfaced(area_rid: RID, area: Area, area_shape_index: int, local_shape_index: int):

	var local_shape_owner = point_area.shape_find_owner(local_shape_index)
	var local_shape_node = point_area.shape_owner_get_owner(local_shape_owner)
	var dif = local_shape_node.global_position - rigidbody.global_position
	dif = local_shape_node.position
	rigidbody.add_force(dif, Vector2(0, 98))
		

	

	

		
		

func set_position(new_position):
	var movement = new_position - global_position
	
	#first move the bodies
	$StaticBody2D.constant_linear_velocity = movement * 60
	
	#then move self
	position = new_position
	reset_physics_interpolation()
			

	


func _physics_process(delta):
	if !"Editor" in str(get_tree().current_scene):
		if !physics_enabled:
			return
		
		

func update_parts():
	sprite.rect_position.x = -(left_width + (part_width * parts) + right_width) / 2
	sprite.rect_size.x = left_width + right_width + part_width * parts

	platform_area_collision_shape.shape.extents.x = (left_width + (part_width * parts) + right_width) / 2 + 20
	collision_shape.shape.extents.x = (left_width + (part_width * parts) + right_width) / 2

	#calculate the total platform scale
	scale_x = scale.x * (left_width + right_width + part_width * parts) / (left_width + right_width + part_width)
