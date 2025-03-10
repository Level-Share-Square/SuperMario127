extends GameObject

export var custom_preview_position = Vector2(70, 170)
export(Array, Texture) var palette_textures
export var texture_size := Vector2(56, 64)

onready var z_indexer : Node2D = $Node2D
onready var sprite : NinePatchRect = $Node2D/Sprite

var parts : int = 1

func _set_properties():
	savable_properties = ["parts"]
	editable_properties = ["parts"]
	
func _set_property_values():
	set_property("parts", parts, true)

func _input(event):
	if event is InputEventMouseButton and event.is_pressed() and hovered:
		if event.button_index == 5: # Mouse wheel down
			parts -= 1
			if parts < 1:
				parts = 1
			set_property("parts", parts)
		elif event.button_index == 4: # Mouse wheel up
			parts += 1
			set_property("parts", parts)

func update_property(key, value):
	update_parts()

func update_parts():
	if parts < 1:
		parts = 1
	
	sprite.rect_size.y = texture_size.y * parts

func _ready():
	if mode == 1:
		connect("property_changed", self, "update_property")
	
	update_parts()
	
	preview_position = custom_preview_position
	if is_preview:
		z_index = 0
		z_indexer.z_index = 0
	
	if palette != 0:
		z_indexer.texture = palette_textures[palette - 1]
