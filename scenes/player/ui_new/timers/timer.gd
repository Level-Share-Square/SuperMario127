extends TimerBase


onready var timer_display: Label = $Time
onready var name_display: Label = $Time/Name

export var label_text: String = "TIME"
export var show_time_score: bool = false
export var kill_on_end: bool = false

export var p_switch_tick: AudioStream
export var p_switch_end_tick: AudioStream

export var kill_beep_start: AudioStream
export var kill_beep_middle: AudioStream
export var kill_beep_final: AudioStream

var sound_time: float

func _ready():
	set_label(label_text)
	
	var _connect = connect("time_over", self, "kill_player")
	
	if (sound in SOUND_TYPES) == false:
		push_warning("Sound type \"" + sound + "\" not found for timer. Did you mistype?")
		match(sound):
			"switch":
				audio_player.stream = p_switch_tick
				audio_player_secondary.stream = p_switch_end_tick
			"death":
				audio_player.stream = kill_beep_start
				audio_player_secondary.stream = kill_beep_middle

	
	# time scores are always visible when enabled, no need to fade them in
	if show_time_score:
		modulate.a = 1
		return


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
			if time <= 10 and time > 0:
				#this is really hacky but it works and I'll take it working, a signal would probably be better here
				if !tween.is_active() and timer_display.rect_scale != Vector2(1.35, 1.35):
					tween.interpolate_property(
						timer_display,
						"rect_scale",
						Vector2(1, 1),
						Vector2(1.35, 1.35),
						0.2, 
						tween.TRANS_BOUNCE
						)
					tween.start()
				timer_display.modulate.r = ((cos(4*PI*mod_color_time)))+2
				timer_display.modulate.g = ((cos(4*PI*mod_color_time-PI))/4)+.75
				timer_display.modulate.b = ((cos(4*PI*mod_color_time-PI))/4)+.75
		
		timer_display.text = LevelInfo.generate_time_string(time)
		
		if time <= 0:
			time = 0
			time_over()

func kill_player():
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
