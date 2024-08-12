extends Button
class_name ButtonSound

onready var hover_sound : AudioStreamPlayer = get_parent().get_node("%HoverSound") 
onready var click_sound : AudioStreamPlayer = get_parent().get_node("%ClickSound") 

func _ready() -> void:
	#warning-ignore:return_value_discarded
	connect("focus_entered", self, "on_focus_entered")
	#warning-ignore:return_value_discarded
	connect("mouse_entered", self, "on_mouse_entered")
	#warning-ignore:return_value_discarded
	connect("mouse_exited", self, "on_mouse_exited")
	#warning-ignore:return_value_discarded
	connect("pressed", self, "on_pressed")

func on_mouse_entered() -> void:
	grab_focus()
	hover_sound.play()

func on_mouse_exited() -> void:
	release_focus()

func on_focus_entered() -> void:
	hover_sound.play()
	hover_sound.play()

func on_pressed() -> void:
	click_sound.play()
