extends CanvasLayer

onready var canvas_background = $Background
onready var canvas_mask = $Light2D
onready var tween = $Tween

onready var music_node = get_node("/root/music")

const TRANSITION_SCALE_UNCOVER = 11
const TRANSITION_SCALE_COVERED = 0

var transitioning = false

func reload_scene(transition_in_tex, transition_out_tex, transition_time, new_area, clear_vars = false):
	#if the button is invisible, then we're probably not in editing mode, but if it's visible make sure we don't reload the scene while it's switching
	if mode_switcher.get_node("ModeSwitcherButton").invisible or !mode_switcher.get_node("ModeSwitcherButton").switching_disabled:
		var volume_multiplier = music_node.volume_multiplier
		
		transitioning = true

		yield(do_transition_animation(transition_in_tex, transition_time, TRANSITION_SCALE_UNCOVER, TRANSITION_SCALE_COVERED, volume_multiplier, volume_multiplier / 4), "completed")

		if clear_vars:
			CurrentLevelData.level_data.vars = LevelVars.new()
		CurrentLevelData.area = new_area
		var _reload = get_tree().reload_current_scene()
		
		yield(get_tree().create_timer(0.1), "timeout")
		get_tree().paused = false
		
		yield(do_transition_animation(transition_out_tex, transition_time, TRANSITION_SCALE_COVERED, TRANSITION_SCALE_UNCOVER, volume_multiplier / 4, volume_multiplier), "completed")
		
		canvas_background.visible = false
		transitioning = false

func do_transition_animation(transition_texture, transition_time, texture_scale_start, texture_scale_end, volume_start, volume_end):
	tween.stop_all()
		
	canvas_background.visible = true
		
	canvas_mask.texture = transition_texture
		
	# if the start scale is greater, then the screen is transitioning to black
	var to_black = texture_scale_start > texture_scale_end
	tween.interpolate_property(canvas_mask, "texture_scale", texture_scale_start, texture_scale_end, transition_time, Tween.TRANS_CIRC, Tween.EASE_OUT if to_black else Tween.EASE_IN)
	if music_node.volume_multiplier != 0:
		tween.interpolate_property(music_node, "volume_multiplier", volume_start, volume_end, transition_time, Tween.TRANS_CIRC, Tween.EASE_OUT)
	tween.start()
		
	#wait for the tween to finish before returning, and then a little extra time
	yield(tween, "tween_all_completed")
	yield(get_tree().create_timer(0.1), "timeout")
