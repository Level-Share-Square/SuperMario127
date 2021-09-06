extends GameObject

onready var sprite = $Sprite
onready var sprite2 = $Sprite/Sprite2

onready var collision_shape = $StaticBody2D/CollisionShape2D

export var normal_texture : Texture
export var recolorable_texture : Texture 

var color := Color(0, 1, 0)
var parts := 2
var part_height = 16

var last_parts := 2

func _set_properties():
	savable_properties = ["color", "parts"]
	editable_properties = ["color", "parts"]
	
func _set_property_values():
	set_property("color", color, true)
	set_property("parts", parts, true)

func _ready():
	collision_shape.shape = collision_shape.shape.duplicate(true)
	collision_shape.disabled = !enabled
		
	update_parts()

func update_parts():
	sprite.position.y = -(part_height * parts) / 2
	sprite.scale.y = part_height * parts
	
	collision_shape.scale.y = sprite.scale.y

func _process(_delta):
	if color == Color(0, 1, 0):
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
	
	if parts != last_parts:
		update_parts()
	last_parts = parts

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
