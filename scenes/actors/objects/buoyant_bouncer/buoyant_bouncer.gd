extends GameObject


#-------------------------------- GameObject logic -----------------------

export var parts := 1
var last_parts := 1

var physics_enabled := true

export(Array, Texture) var palette_textures


func _set_properties():
	savable_properties = ["strong_bounce_power", "physics_enabled"]
	editable_properties = ["strong_bounce_power", "physics_enabled"]
	
func _set_property_values():
	set_property("strong_bounce_power", strong_bounce_power, 650)
	set_property("physics_enabled", physics_enabled)




#-------------------------------- platform logic -----------------------
	
onready var sprite = $Sprite
onready var platform_area_collision_shape = $bouncecol/Area2D/CollisionShape2D
onready var collision_shape = $bouncecol/CollisionShape2D
onready var watercol_shape = $watercol/det
onready var groundcol_shape = $groundcol/CollisionShape2D
onready var topcol_shape = $topcol/CollisionShape2D

onready var left_width = sprite.patch_margin_left
onready var right_width = sprite.patch_margin_right
onready var part_width = sprite.texture.get_width() - left_width - right_width

onready var strong_bounce = preload("res://scenes/actors/objects/note_block/strong_bounce.wav")
onready var weak_bounce = preload("res://scenes/actors/objects/note_block/weak_bounce.wav")

onready var sound = $AudioStreamPlayer2D


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
var buoyancy = 0.01 # not real buoyancy lol

var cooldown = 0

var bounce_power = 300
var strong_bounce_power = 450

onready var bouncedet = $bouncecol

var in_water = false
var spawn_pos = Vector2(0, 0)

func _ready():
	if palette != 0:
		$Sprite.texture = palette_textures[palette]
	var editor = get_tree().current_scene
	grav = editor.level_area.settings.gravity
	if physics_enabled:
		var _connect = waterdet.connect("area_entered", self, "water_entered")
		var _connect2 = grounddet.connect("body_entered", self, "ground_entered")
		var _connect3 = waterdet.connect("area_exited", self, "water_exited")
	var _connect3 = bouncedet.connect("body_entered", self, "mario_entered")

	
	platform_area_collision_shape.shape = platform_area_collision_shape.shape.duplicate(true)
	collision_shape.shape = collision_shape.shape.duplicate(true)
	watercol_shape.shape = watercol_shape.shape.duplicate(true)
	groundcol_shape.shape = groundcol_shape.shape.duplicate(true)
	topcol_shape.shape = topcol_shape.shape.duplicate(true)

	if !enabled:
		collision_shape.disabled = true

	if !physics_enabled:
		watercol_shape.disabled = true
		groundcol_shape.disabled = true
		platform_area_collision_shape.disabled = true
		can_collide_with_floor = true

	spawn_pos = global_position
	update_parts()

func mario_entered(body):
	if "Character" in str(body):
		bounce(body)

func bounce(body):
	if cooldown != 0:
		return

	cooldown = 0.1
	var normal = transform.y
	
	if "velocity" in body:
		actually_bounce(body)
	elif "velocity" in body.get_parent():
		actually_bounce(body.get_parent())

func actually_bounce(body):
	var normal := transform.y
	var is_weak_bounce := true
	
	if "controllable" in body:
		if !body.controllable:
			return # Don't gbj players
	
	if body.has_method("set_state_by_name"):
		body.set_state_by_name("BounceState", 0)
		if body.inputs[2][0]:
			is_weak_bounce = false
			body.sound_player.play_double_jump_sound()
	
	var x_power = (-bounce_power if is_weak_bounce else -strong_bounce_power) * normal.x
	var y_power = (-bounce_power if is_weak_bounce else -strong_bounce_power) * normal.y
	
	if abs(normal.x) > 0.1:
		body.velocity.x = x_power
		# Test move to ensure the player doesn't end up inside of a tile
		if !body.has_method("test_move"):
			body.position.x += 2 * sign(x_power)
		elif !body.test_move(body.transform, Vector2(2 * sign(x_power), 0)):
			body.position.x += 2 * sign(x_power)
	if abs(normal.y) > 0.1:
		body.velocity.y = y_power
		# Test move to ensure the player doesn't end up inside of a tile
		if !body.has_method("test_move"):
			body.position.y += 2 * sign(y_power)
		elif !body.test_move(body.transform, Vector2(0, 2 * sign(y_power))):
			body.position.y += 2 * sign(y_power)
			# Bounce the player off of the ground if necessary,
			# if this wasn't done the player would stay on the ground, repeatedly bouncing
			if y_power < 0 and body.prev_is_grounded\
			and !body.test_move(body.transform, Vector2(0, 4 * sign(y_power))):
				body.position.y += 4 * sign(y_power)
	
	if "stamina" in body:
		body.stamina = 100
	
	sound.stream = weak_bounce if is_weak_bounce else strong_bounce
	sound.play()

func water_entered(area):
	print(area)
	if "Col" in str(area) or "Area2D" in str(area):
		in_water = true
		for i in waterdet.get_overlapping_areas():
			if "Water" in str(i.owner) or "Lava" in str(i.owner):
				water_array.append(i.owner)
				can_collide_with_floor = false
				
				# Handle water physics
				calculate_corners(area.get_parent())
				rotation_left = atan2(corners[largest-1].y - corners[largest].y, corners[largest-1].x - corners[largest].x)
				slope_left = tan(rotation_left)
				rotation_left += PI #correct the angle
				
				rotation_right = atan2(corners[largest].y - corners[(largest + 1) % 4].y, corners[largest].x - corners[(largest + 1) % 4].x)
				slope_right = tan(rotation_right)
				rotation_right += PI
		if !water_array.empty():
			water = water_array[0]
	else: return
	
func water_exited(area):
	if topdet.get_overlapping_bodies().size() > 0 or topdet.get_overlapping_areas().size() > 0:
		can_collide_with_floor = false
	if "Col" in str(area) or "Area2D" in str(area):
		if "Water" in str(area.owner) or "Lava" in str(area.owner):
			if in_water == true:
				can_collide_with_floor = false
		

func calculate_corners(area):
	var temp_top_left = area.global_position - Vector2(0, 10)
	var temp_top_right = area.transform.xform(Vector2(area.width, - 10))
	var temp_bottom_right = area.transform.xform(Vector2(area.width, area.height))
	var temp_bottom_left = area.transform.xform(Vector2(0, area.height))
	var temp_corners
	var temp_largest
	
	# i could NOT think of a better way to do this sorry
	if area.scale.x < 0 and area.scale.y < 0:
		temp_corners = [temp_bottom_right, temp_bottom_left, temp_top_left, temp_top_right]
	elif area.scale.x < 0:
		temp_corners = [temp_top_right, temp_top_left, temp_bottom_left, temp_bottom_right]
	elif area.scale.y < 0:
		temp_corners = [temp_bottom_left, temp_bottom_right, temp_top_right, temp_top_left]
	else:
		temp_corners = [temp_top_left, temp_top_right, temp_bottom_right, temp_bottom_left]
	
	temp_largest = 0
	for i in range(1, 4):
		if temp_corners[i].y < temp_corners[temp_largest].y:
			temp_largest = i
	if corners.size() != 4 or temp_corners[temp_largest].y < corners[largest].y or waterdet.get_overlapping_areas().size() <= 1:
		corners = temp_corners
		largest = temp_largest

func set_position(new_position):
	var movement = new_position - global_position
	position = new_position
	
func ground_entered(body):
	if "Middle" in str(body):
		in_water = false
		if water != null:
			water = null
		can_collide_with_floor = true
	else:
		return
	print(body)

var corners = []
var largest

var slope_left
var rotation_left
var slope_right
var rotation_right

func _physics_process(delta):
	if cooldown > 0:
		cooldown -= delta
		if cooldown <= 0:
			cooldown = 0
	if !"Editor" in str(get_tree().current_scene):
		if !physics_enabled:
			return
			
		if waterdet.get_overlapping_areas().size() == 0:
			in_water = false
			
		var bounds = Singleton.CurrentLevelData.level_data.areas[Singleton.CurrentLevelData.area].settings.bounds 
		if global_position.x < bounds.position.x * 32 - 300 or global_position.x > bounds.end.x * 32 + 300 or global_position.y > bounds.end.y * 32+ 300:
			global_position = spawn_pos
		var result_vector = global_position
		if is_instance_valid(water) and in_water:
			#global_position.x += (rotation_degrees/90) * 3
			result_vector += Vector2((rotation_degrees/90) * 3.3, 0)
			if water.moving:
				calculate_corners(water)
				
			if global_position.x < corners[largest].x and slope_left != 16331239353195370:
				rotation = lerp_angle(rotation, rotation_left, 0.01)
				#global_position.y = lerp(global_position.y, slope_left * global_position.x + (corners[largest-1].y - slope_left * corners[largest-1].x), 0.1)
				var point = slope_left * global_position.x + (corners[largest-1].y - slope_left * corners[largest-1].x)
				if abs(global_position.y - point) < 20:
					buoyancy = 0.3
				else:
					buoyancy = 0.02
				result_vector = Vector2(result_vector.x, lerp(global_position.y, point, buoyancy))
			else:
				rotation = lerp_angle(rotation, rotation_right, 0.01)
				var point = slope_right * global_position.x + (corners[largest].y - slope_right * corners[largest].x)
				if abs(global_position.y - point) < 20:
					buoyancy = 0.3
				else:
					buoyancy = 0.02
				result_vector = Vector2(result_vector.x, lerp(global_position.y, point, buoyancy))
				
			
			animplay.play("bob")
		else:
			animplay.play("RESET")
			if can_collide_with_floor == false:
				#position.y += grav * 0.4
				result_vector += Vector2(0, grav * 0.4)
			rotation = lerp_angle(rotation, 0, 0.1)
		set_position(result_vector)

func update_parts():
	sprite.rect_position.x = -(left_width + (part_width * parts) + right_width) / 2
	sprite.rect_size.x = left_width + right_width + part_width * parts

	platform_area_collision_shape.shape.extents.x = (left_width + (part_width * parts) + right_width) / 2 + 20
	collision_shape.shape.extents.x = (left_width + (part_width * parts) + right_width) / 2
	watercol_shape.shape.extents.x = (left_width + (part_width * parts) + right_width) / 2
	groundcol_shape.shape.extents.x = (left_width + (part_width * parts) + right_width) / 2
	topcol_shape.shape.extents.x = (left_width + (part_width * parts) + right_width) / 2
	#calculate the total platform scale
	scale_x = scale.x * (left_width + right_width + part_width * parts) / (left_width + right_width + part_width)
