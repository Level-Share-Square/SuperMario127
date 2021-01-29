extends Button

export var window : NodePath
export var starting_position : Vector2
onready var window_node = get_node(window)
onready var hover_sound = $HoverSound
onready var click_sound = $ClickSound
var last_hovered = false


func _process(_delta):
	if is_hovered() and !last_hovered:
		hover_sound.play()
	last_hovered = is_hovered()

func _pressed():
	if window_node.visible:
		window_node.close()
		window_node.rect_position = starting_position
	else:
		window_node.rect_position = starting_position
		window_node.open()
	click_sound.play()
