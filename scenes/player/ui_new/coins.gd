extends Control

onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var counter: Label = $HBoxContainer/Counter

func _ready():
	# see: the comment for these exact lines of code in red_coins.gd
	yield(get_tree(), "physics_frame")
	yield(get_tree(), "physics_frame")
	
	var variables: LevelVars = Singleton.CurrentLevelData.level_data.vars
	variables.connect("coin_collected", self, "collect_coin")
	
	var new_coins: int = variables.coins_collected
	counter.text = str(new_coins).pad_zeros(3)

func collect_coin(new_coins: int):
	counter.text = str(new_coins).pad_zeros(3)
	
	animation_player.stop()
	animation_player.play("collect")
