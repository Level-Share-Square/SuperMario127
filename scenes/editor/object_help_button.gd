extends Button

export var window : NodePath
export var starting_position : Vector2
export var help_text := "This is help text. If you see this, something went wrong."
onready var window_node = get_node(window)
onready var hover_sound = $HoverSound
onready var click_sound = $ClickSound
var last_hovered = false


func _process(_delta):
	if is_hovered() and !last_hovered:
		hover_sound.play()
	last_hovered = is_hovered()

func _pressed():
	click_sound.play()

func open_object_help_window(help_text : String):
	if window_node.visible:
		window_node.close()
		window_node.rect_position = starting_position
	else:
		window_node.rect_position = starting_position
		window_node.open()
