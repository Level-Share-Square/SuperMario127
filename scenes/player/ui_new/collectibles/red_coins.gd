extends Control

onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var fadeout: AnimationPlayer = $Fadeout

onready var counter: Label = $HBoxContainer/Counter

var max_reds: int


func _ready():
	hide()
	var player: LevelPlayer = get_tree().current_scene
	var shared: LevelShared = player.get_shared_node()
	yield(shared, "ready")
	delayed_ready()

func delayed_ready():
	# yield one more frame since the player scene needs to set things up
	yield(get_tree(), "physics_frame")
	
	var variables: LevelVars = CurrentLevelData.vars
	max_reds = CurrentLevelData.level_metadata.collectible_data.red_coin_count
	
	if max_reds > 0:
		show()
		variables.connect("red_coin_collected", self, "collect_coin")
		
		var new_coins: int = variables.red_coins_collected[0]
		update_counter(new_coins)

func collect_coin(new_coins: int):
	update_counter(new_coins)
	
	if new_coins == max_reds:
		fadeout.play("fadeout")
	
	animation_player.stop()
	animation_player.play("collect")

func update_counter(new_coins: int):
	var zeroes_length = str(max_reds).length()
	counter.text = str(new_coins).pad_zeros(zeroes_length) + "/" + str(max_reds)
