extends CanvasLayer

onready var canvas_background = $Background
onready var canvas_mask = $Light2D
onready var tween = $Tween
onready var transition_audio = $TransitionAudio

signal transition_finished

onready var cutout_circle = preload("res://scenes/actors/mario/misc/cutout_circle.png") #at some point move the rest of the cutouts here

onready var music_node = Singleton.Music

const DEFAULT_TRANSITION_TIME = 0.75
const TRANSITION_SCALE_UNCOVER = 11
const TRANSITION_SCALE_COVERED = 0

var transitioning = false

const DARK_MODE_TRANSITION_COLOR = Color(0, 0, 0, 1)
const TRANSITION_COLOR = Color(1, 1, 1, 1)
var chosen_transition_color = Color(1, 1, 1, 1)

func _ready():
	Singleton2.connect("dark_mode_toggled", self, "_dark_mode_toggled")

func reload_scene(transition_in_tex = cutout_circle, transition_out_tex = cutout_circle, transition_time = 0.5, new_area = -1, clear_vars = false, r_press = true):
	#if the button is invisible, then we're probably not in editing mode, but if it's visible make sure we don't reload the scene while it's switching
	if Singleton.ModeSwitcher.get_node("ModeSwitcherButton").invisible or !Singleton.ModeSwitcher.get_node("ModeSwitcherButton").switching_disabled:
		var volume_multiplier = Singleton.Music.volume_multiplier

		yield(do_transition_animation(transition_in_tex, transition_time, TRANSITION_SCALE_UNCOVER, TRANSITION_SCALE_COVERED, volume_multiplier, volume_multiplier / 4, false, true), "completed")
		
		Singleton.CurrentLevelData.stop_tracking_time_score()
		if !r_press:
			get_tree().reload_current_scene()
		if new_area != -1:
			Singleton.CurrentLevelData.area = new_area
			
		if r_press:
			GhostArrays.reload = get_tree().reload_current_scene()
		
		yield(get_tree().create_timer(0.1), "timeout")
		get_tree().paused = false
		
		yield(do_transition_animation(transition_out_tex, transition_time, TRANSITION_SCALE_COVERED, TRANSITION_SCALE_UNCOVER, volume_multiplier / 4, volume_multiplier, false, true), "completed")

func do_transition_fade(transition_time : float = DEFAULT_TRANSITION_TIME, start_color : Color = Color(0, 0, 0, 0), end_color : Color = Color(0, 0, 0, 1), reverse_after : bool = true):
	canvas_background.mouse_filter = canvas_background.MOUSE_FILTER_STOP
	canvas_mask.texture_scale = TRANSITION_SCALE_COVERED
	var to_black = start_color.a > end_color.a
	canvas_background.color = start_color
	tween.interpolate_property(canvas_background, "color", start_color, end_color, transition_time, Tween.TRANS_LINEAR, Tween.EASE_OUT if to_black else Tween.EASE_IN)
	tween.start()
	
	# wait for the tween to finish before returning, and then a little extra time, then wait some more if tilesets haven't loaded yet
	yield(tween, "tween_all_completed")
	yield(get_tree().create_timer(0.1), "timeout")
	
	emit_signal("transition_finished")
	
	if reverse_after:
		do_transition_fade(transition_time, end_color, start_color, false)
	else:
		transitioning = false
		canvas_background.mouse_filter = canvas_background.MOUSE_FILTER_IGNORE

func do_transition_animation(transition_texture : StreamTexture = cutout_circle, transition_time : float = DEFAULT_TRANSITION_TIME, texture_scale_start : float = TRANSITION_SCALE_UNCOVER, texture_scale_end : float = TRANSITION_SCALE_COVERED, volume_start : float = -1, volume_end : float = -1, reverse_after : bool = true, stop_temp_music : bool = false):
	canvas_background.color = Color(0, 0, 0, 1)
	transitioning = true
	
	canvas_background.visible = true
	
	canvas_mask.texture = transition_texture
	canvas_mask.texture_scale = texture_scale_start
	
	# if the start scale is greater, then the screen is transitioning to black
	var to_black = texture_scale_start > texture_scale_end
	tween.interpolate_property(canvas_mask, "texture_scale", texture_scale_start, texture_scale_end, transition_time, Tween.TRANS_CIRC, Tween.EASE_OUT if to_black else Tween.EASE_IN)
	tween.start()
	
	# wait for the tween to finish before returning, and then a little extra time
	yield(tween, "tween_all_completed")
	yield(get_tree().create_timer(0.1), "timeout")
	emit_signal("transition_finished")
	
	if reverse_after:
		do_transition_animation(cutout_circle, transition_time, texture_scale_end, texture_scale_start, volume_end, volume_start, false, stop_temp_music)
	else:
		transitioning = false
		canvas_mask.position = Vector2(384, 216) # Reset it, in case a script has modified it before playing the animation

	if stop_temp_music:
		Singleton.Music.stop_temporary_music()
		Singleton.Music.reset_music()

func play_transition_audio():
	transition_audio.play()
	
func _dark_mode_toggled():
	chosen_transition_color = DARK_MODE_TRANSITION_COLOR if Singleton2.dark_mode else TRANSITION_COLOR
