extends TimerBase


onready var timer_display: Label = $Time
onready var name_display: Label = $Time/Name

export var label_text: String = "TIME"
export var show_time_score: bool = false


func _ready():
	set_label(label_text)
	
	# time scores are always visible when enabled, no need to fade them in
	if show_time_score:
		modulate.a = 1
		return


func _physics_process(delta):
	# we don't need anything below this if its just displaying ur time score :)
	if show_time_score:
		timer_display.text = LevelInfo.generate_time_string(Singleton.CurrentLevelData.time_score)
		return
	
	count(delta)


func _update_time_display(display_time: float):
	timer_display.text = LevelInfo.generate_time_string(display_time)


func set_label(new_text: String):
	name_display.text = new_text
