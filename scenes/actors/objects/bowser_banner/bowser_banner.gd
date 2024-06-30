extends GameObject

const rainbow_animation_speed := 2500

onready var collision_shape = $StaticBody2D/CollisionShape2D
onready var animated_sprite = $AnimatedSprite
onready var color_sprite = $Color
export var custom_preview_position = Vector2(70, 170)

var color := Color(1, 0, 0)
var rainbow := false

func _set_properties():
	savable_properties = ["color", "rainbow"]
	editable_properties = ["color", "rainbow"]
	
func _set_property_values():
	set_property("color", color, 1)
	set_property("rainbow", rainbow, true)
func _ready():
	collision_shape.disabled = !enabled
	preview_position = custom_preview_position
	if is_preview:
		z_index = 0
		$AnimatedSprite.z_index = 0
	$AnimatedSprite.animation = String(palette)
	$Color.animation = String(palette)
		
func _process(delta):
	if color == Color(1, 0, 0):
		$Color.visible = false
	else:
		$Color.visible = true
		$Color.modulate = color
	if rainbow:
		# Hue rotation
		color.h = float(OS.get_ticks_msec() % rainbow_animation_speed) / rainbow_animation_speed
	
