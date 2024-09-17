extends Control

signal time_over

const FADE_TIME: float = 0.5

onready var timer_display: Label = $Time
onready var name_display: Label = $Time/Name
onready var tween := $Tween
onready var tick_sound := $Tick
onready var tick_end_sound := $TickEnd

export var label_text: String = "TIME"
export var show_time_score: bool = false
export var is_counting: bool = true
export var time: float = 0.0
export var sound: bool = false
export var sound_time : float = 0.0


func _ready():
	set_label(label_text)
	
	# time scores are always visible when enabled, no need to fade them in
	if show_time_score:
		timer_display.modulate.a = 1
		return
	
	tween.interpolate_property(
		timer_display, 
		"modulate:a", 
		0, 1,
		FADE_TIME)
	tween.start()


func _physics_process(delta):
	# we don't need anything below this if its just displaying ur time score :)
	if show_time_score:
		timer_display.text = LevelInfo.generate_time_string(Singleton.CurrentLevelData.time_score)
		return
	
	# justt in case the timer is set again right after running out
	if not is_counting and time > 0:
		cancel_time_over()
	
	if is_counting:
		time -= delta
		
		if sound:
			sound_time -= delta
			if sound_time <= 0:
				if time > 3:
					tick_sound.play()
				else:
					if !tick_end_sound.playing:
						tick_end_sound.play()
				sound_time = wrapf(time, 0, 1.1)
		
		timer_display.text = LevelInfo.generate_time_string(time)
		
		if time <= 0:
			time = 0
			time_over()


func cancel_time_over():
	is_counting = true
	timer_display.modulate.a = 1
	tween.disconnect("tween_all_completed", self, "queue_free")
	tween.stop_all()


func time_over():
	is_counting = false
	emit_signal("time_over")
	
	tween.connect("tween_all_completed", self, "queue_free")
	tween.interpolate_property(
		timer_display, 
		"modulate:a", 
		1, 0,
		FADE_TIME)
	tween.start()
	

func set_label(new_text: String):
	name_display.text = new_text
