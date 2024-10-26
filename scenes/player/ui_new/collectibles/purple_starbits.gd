extends Control


const ZEROES_LENGTH: int = 3

onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var show_max = $ShowMax
onready var fadeout: AnimationPlayer = $Fadeout

onready var collected = $HBoxContainer/HBoxContainer/Collected
onready var required = $HBoxContainer/HBoxContainer/Required
onready var max_label = $HBoxContainer/HBoxContainer/Required/Max

var max_shown: bool
var max_purples: int
var required_purples: int

var variables: LevelVars = Singleton.CurrentLevelData.level_data.vars


func _ready():
	# sigh, have to wait for the player scene to finish up their work
	yield(get_tree(), "physics_frame")
	yield(get_tree(), "physics_frame")
	
	max_purples = variables.max_purple_starbits
	
	if max_purples > 0:
		visible = true
		update_required_purples()
	
	if required_purples > 0:
		variables.connect("purple_starbit_collected", self, "collect_coin")
		
		var new_coins: int = variables.purple_starbits_collected[Singleton.CurrentLevelData.area][0]
		update_counter(new_coins)

func collect_coin(new_coins: int):
	update_counter(new_coins)
	
	animation_player.stop()
	animation_player.play("collect")

func update_counter(new_coins: int):
	update_required_purples()
	
	if new_coins == required_purples:
		fadeout.play("fadeout")
	
	collected.text = str(new_coins).pad_zeros(ZEROES_LENGTH)
	required.text = str(required_purples).pad_zeros(ZEROES_LENGTH)
	max_label.text = "(" + str(max_purples) + ")"

func update_required_purples():
	var current_required_purples = variables.required_purple_starbits[Singleton.CurrentLevelData.area]
	if len(current_required_purples) > 0:
		if len(current_required_purples) > 1:
			if variables.purple_starbits_collected[Singleton.CurrentLevelData.area][0] >= required_purples:
				variables.required_purple_starbits[Singleton.CurrentLevelData.area].pop_front()
			required_purples = variables.required_purple_starbits[Singleton.CurrentLevelData.area][0]


func child_entered_tree(node):
	var parent := get_parent()
	call_deferred("move_child", self, parent.get_child_count()-1)
#	parent.move_child(self, parent.get_child_count() - 1)
