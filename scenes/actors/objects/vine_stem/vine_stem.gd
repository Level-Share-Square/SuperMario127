extends GameObject

export var custom_preview_position = Vector2(70, 170)
export(Array, Texture) var palette_textures


onready var sprite = $Node2D/Sprite
onready var left_width = sprite.patch_margin_top
onready var right_width = sprite.patch_margin_bottom
onready var part_width = 64




var scale_y : float
export var override_part_width := 0 # If this value is not equal to 0, this'll replace part_width with it's value

export var parts := 1
var last_parts := 1

#func _set_properties():
#	savable_properties = ["parts"]
#	editable_properties = ["parts"]
	
func _register_properties():
	register_property(4, "parts", parts, true)
	
func _ready():
	preview_position = custom_preview_position
	if is_preview:
		z_index = 0
	
	if palette != 0:
		sprite.texture = palette_textures[palette - 1]
		
func _unhandled_input(event: InputEvent) -> void:
	parts_input_handler(event,self)

func _process(_delta):
	if parts != last_parts:
		update_parts()
	last_parts = parts
	
	if palette != 0 and sprite.texture != palette_textures[palette-1]:
		sprite.texture = palette_textures[palette - 1]
	
func update_parts():
	sprite.rect_position.y = -(left_width + (part_width * parts) + right_width) / 2
	sprite.rect_size.y = left_width + right_width + part_width * parts

	#calculate the total platform scale
	scale_y = scale.y * (left_width + right_width + part_width * parts) / (left_width + right_width + part_width)
