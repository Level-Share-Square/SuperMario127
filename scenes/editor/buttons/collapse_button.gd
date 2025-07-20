extends ButtonSound

export var menu_path: NodePath
onready var menu: Control = get_node(menu_path)
export var blocker_path: NodePath
onready var blocker: Control = get_node(blocker_path)

onready var tween := Tween.new()
var menu_visible: bool = true

export var open_text: String
export var close_text: String

func _ready():
	add_child(tween)
	connect("pressed", self, "toggle_menu")

func toggle_menu():
	text = open_text if menu_visible else close_text
	menu_visible = not menu_visible
	if menu_visible:
		menu.show()
		blocker.hide()
		tween.interpolate_property(
			menu, "rect_min_size:x", menu.rect_min_size.x, menu.get_child(0).rect_size.x, 
			0.4, Tween.TRANS_CUBIC, Tween.EASE_OUT
		)
		tween.start()
	else:
		blocker.show()
		tween.interpolate_callback(menu, 0.4, "hide")
		tween.interpolate_property(
			menu, "rect_min_size:x", menu.rect_min_size.x, 0, 
			0.4, Tween.TRANS_CUBIC, Tween.EASE_OUT
		)
		tween.start()
