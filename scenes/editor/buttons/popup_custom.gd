extends ButtonSound

onready var tween := Tween.new()
onready var menu: PanelContainer = $Menu
var menu_visible: bool = false

func _ready():
	add_child(tween)
	menu.rect_scale.y = 0
	rect_min_size.x = 0
	connect("pressed", self, "toggle_menu")

func toggle_menu():
	menu_visible = not menu_visible
	if menu_visible:
		tween.interpolate_property(
			self, "rect_min_size:x", rect_min_size.x, menu.rect_size.x, 
			0.2, Tween.TRANS_CUBIC, Tween.EASE_OUT
		)
		tween.interpolate_property(
			menu, "rect_scale:y", menu.rect_scale.y, 1, 
			0.2, Tween.TRANS_CUBIC, Tween.EASE_OUT, 0.1
		)
		tween.start()
	else:
		tween.interpolate_property(
			self, "rect_min_size:x", rect_min_size.x, 0, 
			0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT, 0.1
		)
		tween.interpolate_property(
			menu, "rect_scale:y", menu.rect_scale.y, 0, 
			0.2, Tween.TRANS_CUBIC, Tween.EASE_OUT
		)
		tween.start()
