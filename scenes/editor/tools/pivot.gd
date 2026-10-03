extends TextureButton

onready var pivot_toggle = $"%PivotToggleButton"
onready var selector: ObjectSelector = owner

onready var pivot_off_icon: StreamTexture = preload("res://assets/icons/PivotOff.svg")
onready var pivot_on_icon: StreamTexture = preload("res://assets/icons/PivotOn.svg")

func get_position_centered(position: Vector2 = selector.fill_rect.get_center()) -> Vector2:
	return position - rect_size/2

func _ready():
	rect_position = get_position_centered()
	connect("pressed", self, "on_pressed")
	pivot_toggle.connect("pressed", self, "toggle_pivot")
	
func _process(delta):
	if pressed:
		rect_global_position = get_position_centered(selector.get_mouse_pos())

func toggle_pivot():
	if visible:
		visible = false
		pivot_toggle.icon = pivot_off_icon
	else:
		visible = true
		rect_position = get_position_centered()
		pivot_toggle.icon = pivot_on_icon
