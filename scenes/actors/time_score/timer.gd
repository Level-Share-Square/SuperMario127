extends Control

signal time_over

const FADE_TIME: float = 0.5
var sound_time : float = 0.0
var sound_types := {0: "none", 1: "switch", 2: "death"}

onready var timer_display: Label = $Time
onready var name_display: Label = $Time/Name
onready var tween := $Tween
onready var audio_player := $sound
onready var audio_player_secondary := $sound_secondary

export var label_text: String = "TIME"
export var show_time_score: bool = false
export var is_counting: bool = true
export var time: float = 0.0
export var kill_on_end: bool = false
export var sound: String = "none"

export var p_switch_tick: AudioStream
export var p_switch_end_tick: AudioStream

export var kill_beep_start: AudioStream
export var kill_beep_middle: AudioStream
export var kill_beep_final: AudioStream


func _ready():
	set_label(label_text)
	
	# time scores are always visible when enabled, no need to fade them in
	if show_time_score:
		timer_display.modulate.a = 1
		return
	
	if (sound in sound_types) == false:
		push_warning("Sound type \"" + sound + "\" not found for timer. Did you mistype?")
	match(sound):
		"switch":
			audio_player.stream = p_switch_tick
			audio_player_secondary.stream = p_switch_end_tick
		"death":
			audio_player.stream = kill_beep_start
			audio_player_secondary.stream = kill_beep_middle
	
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
		
		match(sound):
			"switch":
				sound_time -= delta
				if sound_time <= 0:
					if time > 3:
						audio_player.play()
					else:
						if !audio_player_secondary.playing:
							audio_player_secondary.play()
					sound_time = wrapf(time, 0, 1.1)
			"death":
				sound_time -= delta
				if sound_time <= 0:
					if time <= 10:
						if time > 6:
							audio_player.play()
						elif time > 2:
							if !audio_player_secondary.playing:
								audio_player_secondary.play()
						elif time > 0:
							audio_player.stream = kill_beep_final
							if !audio_player.playing:
								audio_player.play()
						sound_time = wrapf(time, 0, 1)
				
		if kill_on_end:
			var mod_color_time = wrapf(time, 0, 1)
			if time <= 10:
				if !tween.is_active() and timer_display.rect_scale != Vector2(1.25, 1.25):
					tween.interpolate_property(
						timer_display,
						"rect_scale",
						Vector2(1, 1),
						Vector2(1.25, 1.25),
						0.2)
					tween.start()
				timer_display.modulate.r = ((cos(4*PI*mod_color_time)))+2
				timer_display.modulate.g = ((cos(4*PI*mod_color_time-PI))/4)+.75
				timer_display.modulate.b = ((cos(4*PI*mod_color_time-PI))/4)+.75
		
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
	
	if !kill_on_end:
		tween.connect("tween_all_completed", self, "queue_free")
		tween.interpolate_property(
			timer_display, 
			"modulate:a", 
			1, 0,
			FADE_TIME)
		tween.start()
	else:
		var player = get_node("/root").get_node("Player").get_node(get_node("/root").get_node("Player").character)
		var player2 = get_node("/root").get_node("Player").get_node(get_node("/root").get_node("Player").character2)
		if is_instance_valid(player):
			if !player.dead and player.controllable:
				player.kill("green_demon")
		if is_instance_valid(player2):
			if !player2.dead and player2.controllable:
				player2.kill("green_demon")
	

func set_label(new_text: String):
	name_display.text = new_text
