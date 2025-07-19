extends ButtonSound

export var menu_path: NodePath
onready var menu: PanelContainer = get_node(menu_path)

onready var tween := Tween.new()
var menu_visible: bool = false

func _ready():
	add_child(tween)
	menu.rect_scale.y = 0
	connect("pressed", self, "toggle_menu")

func toggle_menu():
	menu_visible = not menu_visible
	if menu_visible:
		tween.interpolate_property(
			menu, "rect_scale:y", menu.rect_scale.y, 1, 
			0.2, Tween.TRANS_CUBIC, Tween.EASE_OUT
		)
		tween.start()
	else:
		tween.interpolate_property(
			menu, "rect_scale:y", menu.rect_scale.y, 0, 
			0.2, Tween.TRANS_CUBIC, Tween.EASE_OUT
		)
		tween.start()
