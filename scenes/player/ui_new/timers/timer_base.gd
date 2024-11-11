class_name TimerBase
extends Control

signal time_over

onready var tween := $Tween
const FADE_TIME: float = 0.5
const SOUND_TYPES := {0: "none", 1: "switch", 2: "death"}

onready var audio_player := $Sound
onready var audio_player_secondary := $SoundSecondary

export var is_counting: bool = true
export var time: float = 0.0
export var sound: String = "none"


func _ready():
	tween.interpolate_property(
		self, 
		"modulate:a", 
		0, 1,
		FADE_TIME)
	tween.start()
	

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
