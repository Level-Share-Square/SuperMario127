extends CanvasLayer

onready var canvas_background = $Background
onready var canvas_mask = $Light2D
onready var canvas_tween = $Tween

var can_load = true

func reload_scene(transition_in_tex, transition_out_tex, transition_time):
	canvas_tween.stop_all()
	
	canvas_background.visible = true
	
	canvas_mask.texture_scale = 50
	canvas_mask.texture = transition_in_tex
	
	canvas_tween.interpolate_property(canvas_mask, "texture_scale",
		11, 0, transition_time,
		Tween.TRANS_CIRC, Tween.EASE_OUT)
	canvas_tween.start()
	
	canvas_tween.interpolate_property(music, "volume_multiplier",
		1, 10, transition_time,
		Tween.TRANS_CIRC, Tween.EASE_OUT)
	canvas_tween.start()
	
	yield(canvas_tween, "tween_completed")
	yield(get_tree().create_timer(0.1), "timeout")
	
	get_tree().reload_current_scene()
	
	canvas_mask.texture = transition_out_tex
	
	canvas_tween.interpolate_property(canvas_mask, "texture_scale",
		0, 11, transition_time,
		Tween.TRANS_CIRC, Tween.EASE_IN)
	canvas_tween.start()
	
	yield(canvas_tween, "tween_completed")
	
	canvas_background.visible = false
