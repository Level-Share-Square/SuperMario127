class_name TimerBase
extends Control

signal time_over

onready var tween := $Tween
const FADE_TIME: float = 0.5

export var is_counting: bool = true
export var time: float = 0.0


func _ready():
	tween.interpolate_property(
		self, 
		"modulate:a", 
		0, 1,
		FADE_TIME)
	tween.start()


func count(delta):
	# justt in case the timer is set again right after running out
	if not is_counting and time > 0:
		cancel_time_over()
	
	if is_counting:
		time -= delta
		_update_time_display(time)
		
		if time <= 0:
			time = 0
			time_over()


func _update_time_display(display_time: float):
	pass


func cancel_time_over():
	is_counting = true
	modulate.a = 1
	tween.disconnect("tween_all_completed", self, "queue_free")
	tween.stop_all()


func time_over():
	is_counting = false
	emit_signal("time_over")
	tween.connect("tween_all_completed", self, "queue_free")
	tween.interpolate_property(
		self, 
		"modulate:a", 
		1, 0,
		FADE_TIME)
	tween.start()
