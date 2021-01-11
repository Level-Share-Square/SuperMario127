extends Node

var current_checkpoint_id := -1
var current_spawn_pos := Vector2(-999, -999)
var current_coins := 0
var current_red_coins := [0, []]
var current_shine_shards := [0, []]
var liquid_positions := []
var nozzles_collected := []

func reset():
	current_checkpoint_id = -1
	current_spawn_pos = Vector2(-999, -999)
	current_coins = 0
	current_red_coins = [0, []]
	current_shine_shards = [0, []]
	liquid_positions = []
	nozzles_collected = ["null"]
