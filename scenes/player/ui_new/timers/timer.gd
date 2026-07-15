extends TimerBase


onready var timer_display: Label = $Time
onready var name_display: Label = $Time/Name
onready var death_sound_timer: Timer = $DeathSoundTimer
onready var death_sound_type: int = 0
onready var ticks_left: int = 0

export var label_text: String = "TIME LEFT"
export var show_time_score: bool = false
export var kill_on_end: bool = false

export var p_switch_tick: AudioStream
export var p_switch_end_tick: AudioStream

export var kill_beep_start: AudioStream
export var kill_beep_middle: AudioStream
export var kill_beep_final: AudioStream
export var timer_finished: AudioStream

enum DeathSoundType {NO_SOUND = 0,BEEP_START = 1,BEEP_MIDDLE = 2,BEEP_FINAL = 3,FINISHED = 4}

var sound_time: float

signal play_sound

func _ready():
	set_label(label_text)
	
	var _connect = connect("time_over", self, "kill_player")
	death_sound_timer.connect("timeout",self,"handle_death_timer")
	
	match(sound):
		"switch":
			audio_player.stream = p_switch_tick
			audio_player_secondary.stream = p_switch_end_tick
		"death":
			audio_player.stream = kill_beep_start
			audio_player.volume_db = -4
			audio_player_secondary.stream = kill_beep_middle
			audio_player_secondary.volume_db = -4

	
	# time scores are always visible when enabled, no need to fade them in
	if show_time_score:
		modulate.a = 1
		return
		
	death_sound_timer.stop()
	death_sound_timer.set_one_shot(true)


func _physics_process(delta):
	# we don't need anything below this if its just displaying ur time score :)
	if show_time_score:
		timer_display.text = LevelInfo.generate_time_string(CurrentLevelData.time_score)
		return
	
	var player = get_node("/root").get_node("Player").get_node(get_node("/root").get_node("Player").character)
	# justt in case the timer is set again right after running out
	if not is_counting and time > 0 && !player.shine_cutscene:
		cancel_time_over()
	
	if is_counting:
		death_sound_timer.paused = false
		time -= fps_util.PHYSICS_DELTA
		sound_time = wrapf(time, 0, 1)
		match(sound):
			"switch":
				sound_time -= fps_util.PHYSICS_DELTA
				if sound_time <= 0:
					if time > 3:
						audio_player.play()
					else:
						if !audio_player_secondary.playing:
							audio_player_secondary.play()
					sound_time = wrapf(time, 0, 1.1)
			"death":
				if (death_sound_timer.is_stopped() and death_sound_type != DeathSoundType.FINISHED):
					
					if time > 11:
						death_sound_timer.start(time - 11)
					else:
						death_sound_timer.set_one_shot(false)
						
						if time > 6:
							
							death_sound_type = DeathSoundType.BEEP_START
							death_sound_timer.start(time - floor(time))
							ticks_left = int(time) - 6
						
						elif time > 2:
							
							death_sound_type = DeathSoundType.BEEP_MIDDLE
							death_sound_timer.start(time - floor(time))
							ticks_left = int(time) - 2
						
						else:
							
							death_sound_type = DeathSoundType.BEEP_FINAL
							death_sound_timer.start(time - floor(time))
							ticks_left = 1
				
		if kill_on_end:
			var mod_color_time = wrapf(time, 0, 1)
			if time <= 10 and time > 0:
				#this is really hacky but it works and I'll take it working, a signal would probably be better here
				if !tween.is_active() and timer_display.rect_scale != Vector2(1.25, 1.25):
					tween.interpolate_property(
						timer_display,
						"rect_scale",
						Vector2(1, 1),
						Vector2(1.25, 1.25),
						0.2, 
						Tween.TRANS_QUAD,
						Tween.EASE_IN_OUT
						)
					tween.start()
				timer_display.modulate.r = ((cos(4*PI*mod_color_time)))+2
				timer_display.modulate.g = ((cos(4*PI*mod_color_time-PI))/4)+.75
				timer_display.modulate.b = ((cos(4*PI*mod_color_time-PI))/4)+.75
		
		timer_display.text = LevelInfo.generate_time_string(time)
		
		if time <= 0:
			time = 0
			time_over()
	else:
		death_sound_timer.paused = true

func kill_player():
	if !kill_on_end:
		return
	
	var player = get_tree().get_current_scene().get_node(get_tree().get_current_scene().character)
	
	if is_instance_valid(player):
		if !player.dead:
			player.kill("timer")

func handle_death_timer():
	
	match (death_sound_type):
		
		DeathSoundType.NO_SOUND:
			
			death_sound_timer.start(1)
			death_sound_timer.set_one_shot(false)
			
			death_sound_type = DeathSoundType.BEEP_START
			ticks_left = 4 # 4 ticks of the timer until transitioning to the next sound type
		
		DeathSoundType.BEEP_START:
			
			play_timer_sound(kill_beep_start)
			ticks_left -= 1
			
			if (ticks_left == 0):
				
				death_sound_type = DeathSoundType.BEEP_MIDDLE
				ticks_left = 4
		
		DeathSoundType.BEEP_MIDDLE:
			
			play_timer_sound(kill_beep_middle)
			ticks_left -= 1
			
			if (ticks_left == 0):
				
				death_sound_type = DeathSoundType.BEEP_FINAL
				ticks_left = 2
		
		DeathSoundType.BEEP_FINAL:
			
			play_timer_sound(kill_beep_final)
			ticks_left -= 1
			
			if (ticks_left == 0):
				
				death_sound_type = DeathSoundType.FINISHED
		
		DeathSoundType.FINISHED:
			
			play_timer_sound(timer_finished)
			death_sound_timer.stop()

func set_label(new_text: String):
	name_display.text = new_text

func play_timer_sound(stream : AudioStream):
	audio_player.stream = stream
	audio_player_secondary.stream = stream
	
	if !audio_player.playing:
		audio_player.play()
	else:
		audio_player_secondary.play()
	
