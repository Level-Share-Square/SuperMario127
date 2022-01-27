extends GameObject


#-------------------------------- GameObject logic -----------------------

var parts := 1
var last_parts := 1

func _set_properties():
	savable_properties = ["parts"]
	editable_properties = ["parts"]
	
func _set_property_values():
	set_property("parts", parts, 1)

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






#-------------------------------- platform logic -----------------------

onready var body = $KinematicBody2D
onready var sprite = $Sprite
onready var screw = $Screw
onready var area = $FloorTouchArea

onready var platform_area_collision_shape = $KinematicBody2D/Area2D/CollisionShape2D
onready var area_collision_shape = $FloorTouchArea/CollisionShape2D
onready var collision_shape = $KinematicBody2D/CollisionShape2D

var buffer := -5

var tilt := 0.0

var rotation_speed := 0.0

const HALF_PI = PI/2

onready var left_width = sprite.patch_margin_left
onready var right_width = sprite.patch_margin_right
onready var part_width = sprite.texture.get_width() - left_width - right_width

var current_weights := []
var scale_x : float

func _ready():
	platform_area_collision_shape.shape = platform_area_collision_shape.shape.duplicate(true)
	area_collision_shape.shape = area_collision_shape.shape.duplicate(true)
	collision_shape.shape = collision_shape.shape.duplicate(true)
	
	if !enabled:
		collision_shape.disabled = true
		area_collision_shape.disabled = true
		platform_area_collision_shape.disabled = true
	
	update_parts()

func update_parts():
	sprite.rect_position.x = -(left_width + (part_width * parts) + right_width) / 2
	sprite.rect_size.x = left_width + right_width + part_width * parts

	platform_area_collision_shape.shape.extents.x = (left_width + (part_width * parts) + right_width) / 2 + 20
	area_collision_shape.shape.extents.x = ((left_width + (part_width * parts) + right_width) / 2) - 6
	collision_shape.shape.extents.x = (left_width + (part_width * parts) + right_width) / 2
	
	#calculate the total platform scale
	scale_x = scale.x * (left_width + right_width + part_width * parts) / (left_width + right_width + part_width)

func _physics_process(delta):
	if mode == 1 or !enabled: # dont do physics if in edit more or disabled
		return
	
	# first, erase any potential null pointers
	for i in range(current_weights.size()):
		if !is_instance_valid(current_weights[i]):
			current_weights.remove(i)
			i -= 1
	
	#-----calculate-----
	
	var weight := 1.0
	
	# calculate delta_rotation based on all weights on the seesaw
	var weight_distribution := 0
	for _body in current_weights:
		if "velocity" in _body and _body.velocity.y < 0: return
		
		var bottom_pos = _body.bottom_pos # all bodies in the array have this property
		var relative_position_x : float = (bottom_pos.global_position.x - body.global_position.x)
		relative_position_x -= sign(relative_position_x)
		
		if _body.has_method("get_weight"): # an object is only supposed to have this method if it has a different weight than 1
			weight = _body.get_weight()
		
		# calculate the influence the body has on the platform based on it's position
		# we could also check if distance_to_floor is 0 but rounding errors exist and we want a smooth experience
		var distance_to_floor = (tan(tilt)*relative_position_x+body.global_position.y) - bottom_pos.global_position.y - 5 * scale.y
		var factor = max(0,1-distance_to_floor/10) / scale_x
		
		weight_distribution += (relative_position_x * factor) * weight if distance_to_floor>0 else 0.0
		weight_distribution = clamp(weight_distribution, -70, 70)
	
	#-----act on self-----
	
	# apply clamped delta_rotation
	tilt += weight_distribution * delta * 0.2
	
	rotation_speed -= tilt * delta * (0.1 if weight_distribution == 0 else 0.01)
	rotation_speed *= pow(0.92,delta*60)
	tilt = clamp(tilt + rotation_speed, -HALF_PI, HALF_PI)

	rotation = lerp_angle(rotation, tilt, delta * 30 * weight)
	
	body.rotation = 0 #necessary because godot
	
	screw.global_rotation = 0.0
	
	#-----act on other bodies-----
	
	# rotate every body by the difference in rotation and add a sliding vector based on the seesaws tilt
	# basically emulating gravitational pull while on the floor
	#for _body in current_weights:
	#	var bottom_pos = _body.bottom_pos # all bodies in the array have this property
	#	var relative_position : Vector2 = bottom_pos.global_position - body.global_position
	#	_body.global_position = position + (relative_position+Vector2(delta*rotation*200,0)).rotated(rotation-last_rotation)-bottom_pos.position

func _on_FloorTouchArea_body_entered(_body):
	if _body.get("bottom_pos"): #body needs to have this property, it's a good indicator for a living actor
		current_weights.append(_body)

func _on_FloorTouchArea_body_exited(_body):
	current_weights.erase(_body)
