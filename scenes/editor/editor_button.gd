class_name EditorButton
extends ButtonSound


onready var label: Label = get_node("%Text")
onready var content = get_node("%Content")
onready var content_box = get_node("%ContentBox")
onready var content_mat = get_node("%ContentMat")

var icon_texture_rect: TextureRect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
#	var self_path = String(get_path()) + ":text"
#	var test: Array = get_node_and_resource(NodePath(self_path))
#	print(test[0].get_indexed(test[2]))
	
	update_text()
	update_text_styles()
	
	if is_instance_valid(icon):
		create_icon()
		icon = null
	
	content.toggle = toggle_mode
	rect_min_size = content_mat.get_minimum_size()


func _process(delta) -> void:
	update_text_styles()


func update_text() -> void:
	if not text == "":
		label.text = text
		text = ""
	else:
		label.visible = false
	
	label.add_font_override("font", get_font("font"))


func update_text_styles() -> void:
	if is_hovered():
		if pressed:
			label.add_color_override("font_color", get_color("font_color_hover_pressed"))
		else:
			label.add_color_override("font_color", get_color("font_color_hover"))
	else:
		if pressed:
			label.add_color_override("font_color", get_color("font_color_pressed"))
		else:
			label.add_color_override("font_color", get_color("font_color"))


func create_icon():
	var texture_rect = TextureRect.new()
	texture_rect.texture = icon
	texture_rect.expand = true
	texture_rect.stretch_mode = texture_rect.STRETCH_KEEP_ASPECT_CENTERED
	texture_rect.mouse_filter = MOUSE_FILTER_IGNORE
	texture_rect.rect_min_size = Vector2(label.get_minimum_size().y, label.get_minimum_size().y)
	
	content_box.add_child(texture_rect)
	
	if icon_align == ALIGN_LEFT:
		content_box.move_child(texture_rect, 0)
	
	icon_texture_rect = texture_rect
