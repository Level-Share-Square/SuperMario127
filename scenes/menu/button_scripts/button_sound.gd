extends Button
class_name ButtonSound


onready var hover_sound: AudioStreamPlayer = get_parent().get_node("%HoverSound") 
onready var click_sound: AudioStreamPlayer = get_parent().get_node("%ClickSound") 


export var hover_override: String
export var click_override: String

func _process(delta):
	if get_child_count() > 0:
		for child in get_children():
			if "@@" in child.name and child is Control:
				child.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _ready() -> void:
	if hover_override != "":
		hover_sound = get_parent().get_node("%" + hover_override)
	if click_override != "":
		click_sound = get_parent().get_node("%" + click_override)
	
	#warning-ignore:return_value_discarded
	connect("focus_entered", self, "on_focus_entered")
	#warning-ignore:return_value_discarded
	connect("mouse_entered", self, "on_mouse_entered")
	#warning-ignore:return_value_discarded
	connect("mouse_exited", self, "on_mouse_exited")
	#warning-ignore:return_value_discarded
	connect("pressed", self, "on_pressed")


func on_mouse_entered() -> void:
	if disabled: return
	if focus_mode != FOCUS_NONE:
		grab_focus()
	hover_sound.play()


func on_mouse_exited() -> void:
	if disabled: return
	release_focus()


func on_focus_entered() -> void:
	if disabled: return
	hover_sound.play()


func on_pressed() -> void:
	click_sound.play()
