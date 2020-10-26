extends Control

class_name Screen

var can_interact : bool = false

# screen_change signal should be emitted with the args current_screen, new_screeen, transition_id (defaults to 0)
# warning-ignore: unused_signal
signal screen_change

func _pre_open_screen() -> void:
	pass 

func _open_screen() -> void:
	pass 

func _close_screen() -> void:
	pass

# the return value is the length of the animation played, if no animation is played it'll be 0
func play_screen_transition(is_fade_out : bool, from_screen_name : String, to_screen_name : String) -> float:
	if !has_node("AnimationPlayer"):
		return 0.0

	var anim_player : AnimationPlayer = get_node("AnimationPlayer")
	var fade_type : String = "out" if is_fade_out else "in"

	# play an animation named default when fading in that's meant to reset to sane values for the animation and for usage
	# even if no trans_in is found the screen should be usable via this
	if !is_fade_out and anim_player.has_animation("default"):
		anim_player.play("default")
		anim_player.seek(0, true)

	# play either a fade in/out animation for a specific screen or a general fade in/out animation
	# the format for specific screen animation names is trans_[fade_type]_[from_screen_name]_[to_screen_name]
	# the format for default screen animation names is trans_[fade_type]_default 
	# this should be pretty clear by looking at screens already implemented, but it's good do document regardless
	if anim_player.has_animation("trans_%s_%s_%s" % [fade_type, from_screen_name, to_screen_name]):
		anim_player.play("trans_%s_%s_%s" % [fade_type, from_screen_name, to_screen_name])
	elif anim_player.has_animation("trans_%s_default" % fade_type):
		anim_player.play("trans_%s_default" % fade_type)
	else:
		# no animation was found, so none was played
		return 0.0 

	# seek to the very start of the animation, if you don't do this there can be a 1 frame flicker of the state of the screen before the animation starts
	anim_player.seek(0, true)

	# return the length of the animation played
	return anim_player.current_animation_length 
