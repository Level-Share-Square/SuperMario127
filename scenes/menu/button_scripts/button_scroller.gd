extends Button


func _ready():
	LastInputDevice.connect("mouse_changed", self, "mouse_changed")
	focus_neighbour_top = get_path_to(self)
	focus_neighbour_bottom = get_path_to(self)


func mouse_changed(is_mouse: bool):
	visible = not is_mouse


export var scroll_path: NodePath
export var scroll_speed: float = 2

onready var scroll: Control = get_node(scroll_path)

func _physics_process(_delta):
	if get_focus_owner() != self: return
	if Input.is_action_pressed("ui_up"):
		set_scroll(-scroll_speed)
	elif Input.is_action_pressed("ui_down"):
		set_scroll(scroll_speed)

func set_scroll(amount: float):
	if scroll is ScrollContainer:
		scroll.get_v_scrollbar().value += amount
	else:
		scroll.get_v_scroll().value += amount
