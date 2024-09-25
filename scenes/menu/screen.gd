extends Control

signal start_transition
signal screen_opened
signal screen_change(new_screen_name)

export var music_id: int = -1
onready var animation_player = $AnimationPlayer
	print(rect_min_size.x)

func transition(new_screen_name: String):
	if is_instance_valid(get_focus_owner()): 
		get_focus_owner().release_focus()
	
	emit_signal("start_transition")
	
	animation_player.play("transition")
	animation_player.connect("animation_finished", self, "animation_finished", [new_screen_name], CONNECT_ONESHOT)

func animation_finished(_anim_name: String, new_screen_name: String):
	emit_signal("screen_change", new_screen_name)
