extends Node

var current_checkpoint_id := -1
var current_spawn_pos := Vector2(-999, -999)
var current_area := 0
var current_coins := 0
var current_red_coins := [0, []]
var current_shine_shards := []
var current_purple_starbits := []
var liquid_positions := []
var nozzles_collected := []
var switch_state := []

func reset():
	current_checkpoint_id = -1
	current_spawn_pos = Vector2(-999, -999)
	current_area = 0
	current_coins = 0
	current_red_coins = [0, []]
	current_shine_shards = []
	current_purple_starbits = []
	liquid_positions = []
	nozzles_collected = ["null"]
	switch_state = []
	
	for index in Singleton.CurrentLevelData.level_data.areas.size():
		current_shine_shards.append([0, []])
		current_purple_starbits.append([0, []])
		liquid_positions.append([])

	Singleton.CurrentLevelData.level_data.vars.init()
