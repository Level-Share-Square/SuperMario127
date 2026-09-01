class_name CheckpointData
extends Resource

var current_checkpoint_id := -1
var current_spawn_pos := Vector2(-999, -999)
var current_area := 0
var current_coins := 0
var current_red_coins := [0, []]
var current_shine_shards := []
var current_purple_starbits := []
var current_local_keys := []
var liquid_positions := []
var nozzles_collected := []
var switch_state := []
var activated_shine_ids := []
var current_layer_states := []
var current_layer: String
var nozzle_name: String
var water_left: float = 0
var area_time_left: float = -1

func reset():
	current_checkpoint_id = -1
	current_spawn_pos = Vector2(-999, -999)
	current_area = 0
	current_coins = 0
	current_red_coins = [0, []]
	current_shine_shards = []
	current_purple_starbits = []
	current_local_keys = []
	liquid_positions = []
	nozzles_collected = ["null"]
	switch_state = []
	activated_shine_ids = []
	current_layer_states = []
	nozzle_name = ""
	water_left = 100
	area_time_left = -1
	
	for index in CurrentLevelData.area_headers.size():
		current_shine_shards.append([0, []])
		current_purple_starbits.append([0, []])
		liquid_positions.append([])

	CurrentLevelData.vars.init()
