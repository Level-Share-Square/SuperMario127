extends PanelContainer


onready var animation_player = $AnimationPlayer
onready var animation_player_2 = $AnimationPlayer2

onready var show_timer = $ShowTimer
onready var hide_timer = $HideTimer
onready var record_timer = $RecordTimer

onready var high_score_sound = $HighScore
onready var count_sound = $Count

onready var shine_name = $VBoxContainer/ShineName
onready var shine_backing = $VBoxContainer/ShineName/Backing

onready var record_label = $VBoxContainer/NewRecord
onready var time_label = $VBoxContainer/CenterContainer/TimeScore
onready var time_backing = $VBoxContainer/CenterContainer/TimeScore/Backing

var shown: bool = true
var new_record: bool = true
var time_score: float = 0
var target_score: float = 30
var sound_cooldown: int = 0


func _ready():
	if (
		Singleton.CurrentLevelData.is_hub_level() 
		and not Singleton.CurrentLevelData.shine_kickout_data.empty()
	):
		shine_name.text = Singleton.CurrentLevelData.shine_kickout_data.get("title", "Unknown Shine")
		shine_backing.text = shine_name.text
		target_score = Singleton.CurrentLevelData.shine_kickout_data.get("time_score", 0)
		new_record = Singleton.CurrentLevelData.shine_kickout_data.get("new_record", false)
		Singleton.CurrentLevelData.shine_kickout_data = {}
		Singleton.Music.play_music = false
		show_timer.start()
	else:
		Singleton.Music.play_music = true


func start():
	shown = true
	record_label.hide()
	time_score = 0
	animation_player.play_backwards("transition")


func _physics_process(delta):
	if not shown or time_label.modulate.a <= 0: return
	
	var last_text: String = time_label.text
	time_score = lerp(time_score, target_score, delta * 4)
	time_label.text = "-" + LevelInfo.generate_time_string(time_score) + "-"
	time_backing.text = time_label.text
	
	sound_cooldown -= 1
	if time_label.text != last_text and sound_cooldown <= 0:
		count_sound.play()
		sound_cooldown = 3
	
	if is_equal_approx(stepify(time_score, 0.1), stepify(target_score, 0.1)):
		time_score = target_score
		time_label.text = "-" + LevelInfo.generate_time_string(time_score) + "-"
		time_backing.text = time_label.text
		
		shown = false
		hide_timer.wait_time = 0.5 if new_record else 1
		hide_timer.start()


func hide_ui():
	if new_record:
		new_record = false
		animation_player_2.play("new_record")
		high_score_sound.play()
		record_timer.start()
	else:
		if record_label.is_visible_in_tree():
			animation_player_2.play_backwards("new_record")
		animation_player.play("transition")
		Singleton.Music.play_music = true
