extends Control

onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var fadeout: AnimationPlayer = $Fadeout

onready var counter: Label = $HBoxContainer/Counter

var required_purples: int
var variables: LevelVars = Singleton.CurrentLevelData.level_data.vars

func _ready():
	# sigh, have to wait for the player scene to finish up their work
	yield(get_tree(), "physics_frame")
	yield(get_tree(), "physics_frame")
	
	update_required_purples()
	
	if required_purples > 0:
		visible = true
		variables.connect("purple_starbit_collected", self, "collect_coin")
		
		var new_coins: int = variables.purple_starbits_collected[Singleton.CurrentLevelData.area][0]
		update_counter(new_coins)

func collect_coin(new_coins: int):
	update_counter(new_coins)
	
	if new_coins == required_purples:
		fadeout.play("fadeout")
	
	animation_player.stop()
	animation_player.play("collect")

func update_counter(new_coins: int):
	update_required_purples()
	var zeroes_length = str(required_purples).length()
	counter.text = str(new_coins).pad_zeros(zeroes_length) + "/" + str(required_purples)

func update_required_purples():
	if variables.purple_starbits_collected[Singleton.CurrentLevelData.area][0] >= required_purples:
		if len(variables.required_purple_starbits[Singleton.CurrentLevelData.area]) > 1:
			variables.required_purple_starbits[Singleton.CurrentLevelData.area].pop_front()
			required_purples = variables.required_purple_starbits[Singleton.CurrentLevelData.area][0]
