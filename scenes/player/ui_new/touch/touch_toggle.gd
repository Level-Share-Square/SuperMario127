extends TouchScreenButton


onready var icon_sprite: TextureRect = $Icon

export var normal_icon: StreamTexture
export var pressed_icon: StreamTexture
export var toggle_action: String
export var is_pressed: bool = false


func _ready():
	connect("pressed", self, "set_pressed")


func set_pressed(new_pressed: bool = not is_pressed):
	is_pressed = new_pressed
	icon_sprite.texture = pressed_icon if is_pressed else normal_icon
	commit_action(toggle_action, is_pressed)


func commit_action(action_name: String, is_pressed: bool):
	if action_name == "": return
	var event_action := InputEventAction.new()
	event_action.action = action_name
	event_action.pressed = is_pressed
	Input.parse_input_event(event_action)
