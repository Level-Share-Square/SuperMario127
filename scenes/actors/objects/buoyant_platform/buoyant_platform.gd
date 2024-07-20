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



#-------------------------------- platform logic -----------------------
	
onready var sprite = $Sprite
onready var platform_area_collision_shape = $StaticBody2D/Area2D/CollisionShape2D
onready var collision_shape = $StaticBody2D/CollisionShape2D
onready var watercol_shape = $watercol/det
onready var groundcol_shape = $groundcol/CollisionShape2D
onready var topcol_shape = $topcol/CollisionShape2D

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

var in_water = false

func _ready():
	if palette != 0:
		$Sprite.texture = palette_textures[palette]
	print(palette)
	var editor = get_tree().current_scene
	grav = editor.level_area.settings.gravity
	print(grav)
	if physics_enabled:
		var _connect = waterdet.connect("area_entered", self, "water_entered")
		var _connect2 = grounddet.connect("body_entered", self, "ground_entered")
		var _connect3 = waterdet.connect("area_exited", self, "water_exited")
	if override_part_width != 0:
		part_width = override_part_width

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
		
	update_parts()

func water_entered(area):
	print(area)
	if "Col" in str(area) or "Area2D" in str(area):
		in_water = true
		for i in waterdet.get_overlapping_areas():
			if "Water" in str(i.owner) or "Lava" in str(i.owner):
				water_array.append(i.owner)
				can_collide_with_floor = false
		if !water_array.empty():
			water = water_array[0]
	else: return
	
func water_exited(area):
	if topdet.get_overlapping_bodies().size() > 0 or topdet.get_overlapping_areas().size() > 0:
		can_collide_with_floor = false
	if "Col" in str(area) or "Area2D" in str(area):
		if "Water" in str(area.owner) or "Lava" in str(area.owner):
			if in_water != false:
				can_collide_with_floor = false
		in_water = false
#	water = null
	
func ground_entered(body):
	if "Middle" in str(body):
		in_water = false
		if water != null:
			water = null
		can_collide_with_floor = true
	else:
		return
	print(body)
	
func _physics_process(delta):
	if !"Editor" in str(get_tree().current_scene):
		if is_instance_valid(water):
			
			if rotation_degrees > 0 and rotation_degrees < 90:
				global_position.x += (rotation_degrees/90) * 3
			if rotation_degrees < 0:
				#global_position.x -= (-(rotation_degrees/90) + 4) * 3
				global_position.x += (rotation_degrees/90) * 3
				
				
			
			var top_left = water.global_position
			var top_right = water.transform.xform(Vector2(water.width, 0))
			var bottom_right = water.transform.xform(Vector2(water.width, water.height))
			var bottom_left = water.transform.xform(Vector2(0, water.height))
			var corners = [top_left, top_right, bottom_right, bottom_left]
			
			var largest = 0
			for i in range(1, 4):
				if corners[i].y < corners[largest].y:
					largest = i
				
			var slope
			if global_position.x < corners[largest].x:
				rotation = lerp_angle(rotation, atan2(corners[largest-1].y - corners[largest].y, corners[largest-1].x - corners[largest].x) + PI, 0.01)
				slope = tan(atan2(corners[largest-1].y - corners[largest].y, corners[largest-1].x - corners[largest].x))
				global_position.y = lerp(global_position.y, slope * global_position.x + (corners[largest-1].y - slope * corners[largest-1].x) - 9, 0.1)
			else:
				rotation = lerp_angle(rotation, atan2(corners[largest].y - corners[(largest + 1) % 4].y, corners[largest].x - corners[(largest + 1) % 4].x) + PI, 0.01)
				#rotation_degrees += 180
				slope = tan(atan2(corners[largest].y - corners[(largest + 1) % 4].y, corners[largest].x - corners[(largest + 1) % 4].x))
				global_position.y = lerp(global_position.y, slope * global_position.x + (corners[largest].y - slope * corners[largest].x) - 9, 0.1)
			
			animplay.play("bob")
		else:
			animplay.play("RESET")
			if can_collide_with_floor == false:
				position.y += grav
	
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
