extends GameObject

export var custom_preview_position = Vector2(70, 170)
export(Array, Texture) var palette_textures

onready var area = $Area2D

onready var sprite = $Sprite
onready var left_width = sprite.patch_margin_top
onready var right_width = sprite.patch_margin_bottom
onready var part_width = 48



onready var collision_shape = $Area2D/CollisionShape2D

var scale_y : float
export var override_part_width := 0 # If this value is not equal to 0, this'll replace part_width with it's value

export var parts := 1
var last_parts := 1

func _set_properties():
	savable_properties = ["parts"]
	editable_properties = ["parts"]
	
func _set_property_values():
	set_property("parts", parts, 1)
	
func _ready():
	preview_position = custom_preview_position
	if is_preview:
		z_index = 0
	
	if palette != 0:
		$Sprite.texture = palette_textures[palette - 1]
		
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
	
func update_parts():
	sprite.rect_position.y = -(left_width + (part_width * parts) + right_width) / 2
	sprite.rect_size.y = left_width + right_width + part_width * parts

	
	collision_shape.shape.height = 30 + (part_width * (parts - 1))
	
	#calculate the total platform scale
	scale_y = scale.y * (left_width + right_width + part_width * parts) / (left_width + right_width + part_width)

func is_vanish(body):
	return body.powerup != null and (body.powerup.id == "Vanish" or body.powerup.id == "Metal" or body.powerup.id == "Rainbow")
	
func _physics_process(delta):
	if !enabled:
		return
	for body in area.get_overlapping_bodies():
		if !(body.name.begins_with("Character") and !body.dead and body.controllable):
			return
		
		if !is_vanish(body) and !body.invulnerable:
			body.knockback(global_position)
			if body.global_position.y > (global_position.y - 4):
				body.velocity.y = 55
			body.damage()
			body.sound_player.play_hit_sound()
	
	
