class_name TimerManager
extends Control


const TIMER_SCENE = preload("res://scenes/player/ui_new/timers/timer.tscn")
const RADIAL_TIMER_SCENE = preload("res://scenes/player/ui_new/timers/radial_timer.tscn")

onready var grid: GridContainer = $Timers/Grid
onready var time_score: Control = $Timers/Grid/TimeScore
onready var radial_timers: VBoxContainer = $RadialTimers
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


func add_set_timer(timer_name: String, timer_amount: float, sound: String = "none", kill_on_end: bool = false, visible: bool = true) -> Control:
	var timer_node: Control = grid.get_node_or_null(timer_name)
	if not is_instance_valid(timer_node):
		print("Timer " + timer_name + " doesn't exist, creating timer of same name.")
		timer_node = TIMER_SCENE.instance()
		timer_node.name = timer_name
		
		grid.call_deferred("add_child", timer_node)
	else:
		print("Time for timer " + timer_name + " set to " + str(timer_amount) + ".")
	timer_node.time = timer_amount
	timer_node.sound = sound
	timer_node.kill_on_end = kill_on_end
	return timer_node


func get_timer(timer_name: String) -> Control:
	var timer_node: Control = grid.get_node_or_null(timer_name)
	
	return timer_node


func pause_resume_timer(timer_name: String, pause: bool):
	var timer_node: Control = grid.get_node_or_null(timer_name)
	if not is_instance_valid(timer_node):
		return
	
	timer_node.is_counting = !pause
	print(timer_node)
	print(timer_node.is_counting)


func remove_timer(timer_name: String):
	var timer_node: Control = grid.get_node_or_null(timer_name)
	if not is_instance_valid(timer_node):
		return
	
	timer_node.stop()


func add_radial_timer(timer_name: String, read_node: Node, read_property: String, icon: Texture = null, set_max: bool = true) -> Control:	
	if not is_instance_valid(read_node):
		return null
	
	var timer_node: Control = radial_timers.get_node_or_null(timer_name)
	if not is_instance_valid(timer_node):
		timer_node = RADIAL_TIMER_SCENE.instance()
		timer_node.name = timer_name
		timer_node.icon = icon
		radial_timers.call_deferred("add_child", timer_node)
	
	timer_node.read_node = read_node
	timer_node.read_property = read_property
	if set_max:
		timer_node.call_deferred("set_max_time", read_node[read_property])
	
	return timer_node


## (remove a radial timer by setting the property its reading to 0 or lower)


# testing
#var next_spawn: int = 120
#func _physics_process(delta):
#	next_spawn -= 1
#	if next_spawn <= 0:
#		next_spawn = 60 * rand_range(2, 6)
#		var timer = add_set_timer("Timer " + str(rand_range(0, 200)), rand_range(2, 8))
