class_name LevelVars
extends Resource

signal coin_collected(new_value)
signal red_coin_collected(new_value)
signal shine_shard_collected(new_value)
signal purple_starbit_collected(new_value)
signal local_key_collected(new_value)

signal switch_state_changed
signal hover_fludd_activated
signal turbo_fludd_activated
signal rocket_fludd_activated

var coins_collected := 0
var red_coins_collected := [0, []]
var shine_shards_collected := [[0, []]]
var max_shine_shards := 0
var purple_starbits_collected := [[0, []]]
var max_purple_starbits := 0
var required_purple_starbits = []
var local_keys_collected: Array = []
var nozzles_collected = ["null"]
var teleporters = []
var transition_data: Dictionary = {}
var transition_character_data = []
var transition_character_data_2 = []
var area_transition_helper: AreaTransitionHelper
var liquids = []
var liquid_positions = []
var checkpoints = []
var current_liquid_id = 0
var last_red_coin_id = 0
var switch_state : Array = []
var activated_shine_ids := []
var layer_states := []

func reload():
	coins_collected = CurrentLevelData.checkpoint_data.current_coins
	red_coins_collected = CurrentLevelData.checkpoint_data.current_red_coins.duplicate(true)
	shine_shards_collected = CurrentLevelData.checkpoint_data.current_shine_shards.duplicate(true)
	purple_starbits_collected = CurrentLevelData.checkpoint_data.current_purple_starbits.duplicate(true)
	local_keys_collected = CurrentLevelData.checkpoint_data.current_local_keys.duplicate(true)
	liquid_positions = CurrentLevelData.checkpoint_data.liquid_positions.duplicate(true)
	switch_state = CurrentLevelData.checkpoint_data.switch_state.duplicate(true)
	activated_shine_ids = CurrentLevelData.checkpoint_data.activated_shine_ids.duplicate(true)
	layer_states = CurrentLevelData.checkpoint_data.current_layer_states.duplicate(true)
	required_purple_starbits = []
	for area in CurrentLevelData.area_headers:
		required_purple_starbits.append([0])
		if layer_states.size() != CurrentLevelData.area_headers.size():
			layer_states.append({})
	

func reset_counters():
	max_shine_shards = 0
	max_purple_starbits = 0
	teleporters = []
	liquids = []
	checkpoints = []
	current_liquid_id = 0
	last_red_coin_id = 0
	for area in CurrentLevelData.area_headers:
		required_purple_starbits.append([0])

func init():
	transition_data = {}
	transition_character_data = []
	transition_character_data_2 = []
	area_transition_helper = null

func toggle_switch_state(var channel : int):
	if !switch_state.has(channel):
		switch_state.append(channel)
	else:
		switch_state.erase(channel)
	emit_signal("switch_state_changed", channel)


func activate_fludd(var type : int):
#	if not Singleton.ModeSwitcher.visible:
#		CurrentLevelData.level_info.set_fludd_activated(type, CurrentLevelData.selected_file > -2)
	match(type):
		0:
			emit_signal("hover_fludd_activated")
		1:
			emit_signal("turbo_fludd_activated")
		2:
			emit_signal("rocket_fludd_activated")


func is_fludd_activated(var type : int):
#	return CurrentLevelData.activated_fludds[type]
	return false


func collect_coin(amount: int):
	coins_collected += amount
	emit_signal("coin_collected", coins_collected)


func collect_red_coin(id: Array):
	red_coins_collected[0] += 1
	red_coins_collected[1].append(id)
	emit_signal("red_coin_collected", red_coins_collected[0])


func collect_shine_shard(id: int):
	var area: int = CurrentLevelData.area_id
	shine_shards_collected[area][0] += 1
	shine_shards_collected[area][1].append(id)
	emit_signal("shine_shard_collected", shine_shards_collected[area][0])


func collect_purple_starbit(id: int):
	var area: int = CurrentLevelData.area_id
	purple_starbits_collected[area][0] += 1
	purple_starbits_collected[area][1].append(id)
	emit_signal("purple_starbit_collected", purple_starbits_collected[area][0])

func collect_local_key(id: String):
	if !(id in local_keys_collected):
		local_keys_collected.append(id)
		emit_signal("local_key_collected", id)


func activate_shine(id: String):
	if id in activated_shine_ids:
		return
	
	activated_shine_ids.append(id)


func deactivate_shine(id: int):
	if !(id in activated_shine_ids):
		return
	
	var index = activated_shine_ids.find(id)
	activated_shine_ids.remove(index)
	
func set_layer_states(area_id: int, layers: Array):
	layer_states.clear()
	
	for layer in layers:
		var layer_metadata: LayerMetadata = layer.layer_data.layer_metadata
		
		var layer_state := LayerState.new(
			layer_metadata.order,
			layer_metadata.parallax_distance,
			layer_metadata.layer_tint,
			layer_metadata.layer_opacity
		)
		
		layer_states[area_id][layer_metadata.layer_uuid] = layer_state

#func set_switch_state(var channel : int, value : bool):
#	switch_state[channel] = value
#	emit_signal("switch_state_changed", switch_state[channel], channel)
