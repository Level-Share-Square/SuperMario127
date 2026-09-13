extends GameObject

onready var sprite = $Sprite
onready var textes = $RichTextLabel
# onready var label = $CenterContainer


var slide_to_center_length := 1.25
var text := "This is text. Hello!"

var normal_pos : Vector2

var check_timer := 3.0

var centered := false

export(Array, Texture) var palette_textures
export(Array, Texture) var palette_textures_2

func _register_properties():
	register_property(4, "text", text, false)
	property_tabs.append("sign")

func _ready():
		
	if is_preview:
		z_index = 0
		sprite.z_index = 0
	
	if mode != 1:
		sprite.visible = false
	
	textes.visible = true
	# label.call_deferred("update_sizing")
	update_text(text)


func on_property_changed(key, value):
	if textes && (key == "text"):
		update_text(value)

func update_text(value = "This is text. Hello!"):
	textes.bbcode_text = "[center]" + value + "[/center]"

## probably vestigial
var bubble_text: String setget ,get_bubble_text
func get_bubble_text():
	return text
