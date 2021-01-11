class_name LevelVars

var coins_collected := 0
var red_coins_collected := [0, []]
var max_red_coins := 0
var shine_shards_collected := [0, []]
var max_shine_shards := 0
var nozzles_collected = ["null"]
var doors = []
var transition_data = []
var liquids = []
var checkpoints = []
var current_liquid_id = 0

func _init():
	coins_collected = CheckpointSaved.current_coins
	var red_coins_array = CheckpointSaved.current_red_coins.duplicate()
	red_coins_collected = [red_coins_array[0], red_coins_array[1].duplicate()]
	max_red_coins = 0
	var shine_shards_array = CheckpointSaved.current_shine_shards.duplicate()
	shine_shards_collected = [shine_shards_array[0], shine_shards_array[1].duplicate()]
	max_shine_shards = 0
	nozzles_collected = CheckpointSaved.nozzles_collected.duplicate()
	doors = []
	transition_data = []
	liquids = []
	checkpoints = []
	current_liquid_id = 0
