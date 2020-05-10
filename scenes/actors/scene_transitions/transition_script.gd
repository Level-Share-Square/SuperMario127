extends CanvasLayer

onready var canvas_background = $Background
onready var canvas_mask = $Light2D
onready var canvas_tween = $Tween
onready var music_tween = $MusicTween

var can_load = true
var transitioning = false

func reload_scene(transition_in_tex, transition_out_tex, transition_time, new_area):
	if !mode_switcher.get_node("ModeSwitcherButton").switching_disabled:
		var music_node = get_node("/root/music")
		var old_multiplier = music_node.volume_multiplier
		
		canvas_tween.stop_all()
		
		canvas_background.visible = true
		transitioning = true
		
		canvas_mask.texture_scale = 50
		canvas_mask.texture = transition_in_tex
		
		canvas_tween.interpolate_property(canvas_mask, "texture_scale",
			11, 0, transition_time,
			Tween.TRANS_CIRC, Tween.EASE_OUT)
		canvas_tween.start()
		
		if music_node.volume_multiplier != 0:
			music_tween.interpolate_property(music_node, "volume_multiplier",
				old_multiplier, old_multiplier / 4, transition_time,
				Tween.TRANS_CIRC, Tween.EASE_OUT)
			music_tween.start()
		
		yield(canvas_tween, "tween_completed")
		music.loading = true
		yield(get_tree().create_timer(0.1), "timeout")
		
		CurrentLevelData.area = new_area
		var _reload = get_tree().reload_current_scene()
		
		yield(get_tree().create_timer(0.1), "timeout")
		get_tree().paused = false
		music.loading = false
		
		canvas_mask.texture = transition_out_tex
		
		canvas_tween.interpolate_property(canvas_mask, "texture_scale",
			0, 11, transition_time,
			Tween.TRANS_CIRC, Tween.EASE_IN)
		canvas_tween.start()
		
		if music_node.volume_multiplier != 0:
			music_tween.interpolate_property(music_node, "volume_multiplier",
				old_multiplier / 4, old_multiplier, transition_time,
				Tween.TRANS_CIRC, Tween.EASE_OUT)
			music_tween.start()
		
		yield(canvas_tween, "tween_completed")
		
		canvas_background.visible = false
		transitioning = false
