extends GameObject


#-------------------------------- GameObject logic -----------------------


export(Array, Texture) var palette_textures


export var parts := 1
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
	
onready var sprite = $Sprite
onready var platform_area_collision_shape = $StaticBody2D/Area2D/CollisionShape2D
onready var collision_shape = $StaticBody2D/CollisionShape2D
onready var watercol_shape = $watercol/det
onready var groundcol_shape = $groundcol/CollisionShape2D

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
var water = null
var water_array : Array
var grav

func _ready():
	if palette != 0:
		$Sprite.texture = palette_textures[palette]
	print(palette)
	var editor = get_tree().current_scene
	grav = editor.level_area.settings.gravity
	print(grav)
	var _connect = waterdet.connect("area_entered", self, "water_entered")
	var _connect2 = grounddet.connect("body_entered", self, "ground_entered")
	var _connect3 = waterdet.connect("area_exited", self, "water_exited")
	if override_part_width != 0:
		part_width = override_part_width

	platform_area_collision_shape.shape = platform_area_collision_shape.shape.duplicate(true)
	collision_shape.shape = collision_shape.shape.duplicate(true)
	watercol_shape.shape = watercol_shape.shape.duplicate(true)
	groundcol_shape.shape = groundcol_shape.shape.duplicate(true)
	
	if !enabled:
		collision_shape.disabled = true
		watercol_shape.disabled = true
		groundcol_shape.disabled = true
		platform_area_collision_shape.disabled = true
		
	update_parts()

func water_entered(area):
	if "Col" in str(area):
		for i in waterdet.get_overlapping_areas():
			if "Water" in str(i.owner) or "Lava" in str(i.owner):
				water_array.append(i.owner)
				can_collide_with_floor = false
		if !water_array.empty():
			water = water_array[0]
	else: return
	
func water_exited(area):
	if "Col" in str(area):
		if "Water" in str(area.owner) or "Lava" in str(area.owner):
				can_collide_with_floor = false
	water = null
	
func ground_entered(body):
	if "Middle" in str(body):
		if water != null:
			water = null
		can_collide_with_floor = true
	else:
		return
	print(body)
	
func _physics_process(delta):
	if !"Editor" in str(get_tree().current_scene):
		if is_instance_valid(water):
			position.y = water.position.y - 9
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
	#calculate the total platform scale
	scale_x = scale.x * (left_width + right_width + part_width * parts) / (left_width + right_width + part_width)
