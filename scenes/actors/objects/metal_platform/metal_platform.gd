extends GameObject


#-------------------------------- GameObject logic -----------------------

export var parts := 9
var last_parts := 1

var color := Color(1, 1, 1)

export var normal_texture : Texture
export var recolorable_texture : Texture 

func _set_properties():
	savable_properties = ["parts", "color"]
	editable_properties = ["parts", "color"]

	
func _set_property_values():
	set_property("parts", parts, 1)
	set_property("color", color, 1)

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
	if color == Color(1, 1, 1):
		sprite.texture = normal_texture
		sprite2.visible = false
		sprite.self_modulate = Color(1, 1, 1)
	else:
		sprite.texture = recolorable_texture
		sprite2.visible = true
		sprite.self_modulate = color
		var bright_color = color
		bright_color.s /= 1.5
		bright_color.v *= 1.15
		sprite2.self_modulate = bright_color


#-------------------------------- platform logic -----------------------
	
onready var sprite = $Sprite
onready var sprite2 = $Sprite/Sprite2
onready var platform_area_collision_shape = $StaticBody2D/Area2D/CollisionShape2D
onready var collision_shape = $StaticBody2D/CollisionShape2D

onready var left_width = sprite.patch_margin_left
onready var right_width = sprite.patch_margin_right
onready var part_width = sprite.texture.get_width() - left_width - right_width

var scale_x : float
export var override_part_width := 0 # If this value is not equal to 0, this'll replace part_width with it's value

func _ready():
	if override_part_width != 0:
		part_width = override_part_width

	platform_area_collision_shape.shape = platform_area_collision_shape.shape.duplicate(true)
	collision_shape.shape = collision_shape.shape.duplicate(true)
	
	if !enabled:
		collision_shape.disabled = true
		platform_area_collision_shape.disabled = true
		
	update_parts()

func update_parts():
	sprite.rect_position.x = -(left_width + (part_width * parts) + right_width) / 2
	sprite.rect_size.x = left_width + right_width + part_width * parts
	if(sprite.rect_size != null && sprite2 != null && sprite2.rect_size != null && sprite != null):
		sprite2.rect_size.x = sprite.rect_size.x
	platform_area_collision_shape.shape.extents.x = (left_width + (part_width * parts) + right_width) / 2 + 20
	collision_shape.shape.extents.x = (left_width + (part_width * parts) + right_width) / 2
	
	#calculate the total platform scale
	scale_x = scale.x * (left_width + right_width + part_width * parts) / (left_width + right_width + part_width)
