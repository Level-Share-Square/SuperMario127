extends HBoxContainer

const TIMER_SCENE = preload("res://scenes/actors/time_score/timer.tscn")

onready var grid: GridContainer = $Grid
onready var time_score: Control = $Grid/TimeScore
var shown: bool


func _ready():
	shown = LocalSettings.load_setting("General", "show_timer", false)
	
	LocalSettings.connect("setting_changed", self, "setting_changed")
	update_visibility()


func setting_changed(key: String, new_value: bool):
	if key != "show_timer": return
	shown = new_value
	update_visibility()


# whenever the root scene tree adds a new node we'll execute this (better than executing every frame)
func update_visibility():
	var current_scene = get_tree().get_current_scene()
	if "mode" in current_scene:
		time_score.visible = (shown and current_scene.mode == 0 and Singleton.ModeSwitcher.get_node("ModeSwitcherButton").invisible)
	else:
		time_score.visible = false


func add_timer(timer_name: String, timer_amount: float, sound: String = "none", show: bool = true, kill_on_end: bool = false) -> Control:
	var timer_node: Control = grid.get_node(timer_name)
	if not is_instance_valid(timer_node):
		timer_node = TIMER_SCENE.instance()
		timer_node.name = timer_name
		timer_node.sound = sound
		timer_node.visible = show
		timer_node.kill_on_end = kill_on_end
		
		grid.call_deferred("add_child", timer_node)
	
	timer_node.time = timer_amount
	return timer_node


# testing
#var next_spawn: int = 120
#func _physics_process(delta):
#	next_spawn -= 1
#	if next_spawn <= 0:
#		next_spawn = 60 * rand_range(2, 6)
#		var timer = add_timer("Timer " + str(rand_range(0, 200)), rand_range(2, 8))
