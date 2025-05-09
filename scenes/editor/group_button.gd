extends EditorButton


const base_stylebox_path := "res://scenes/editor/styles/group_button_normal.tres"

export var color := Color(0.454902, 0.454902, 0.454902)

onready var base_stylebox = preload(base_stylebox_path)


func _ready():
	set_color()


func set_color():
	var normal: StyleBoxFlat = base_stylebox.duplicate(true)
	normal.bg_color = color
	normal.bg_color.a = 1
	normal.border_color = color.darkened(.25)
	normal.border_color.a = 1
	
	add_stylebox_override("normal", normal)
	
	if color.get_luminance() < 0.6:
		add_color_override("font_color", Color.white)
	else:
		add_color_override("font_color", Color.black)
