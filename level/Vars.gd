class_name LevelVars

signal switch_state_changed
signal hover_fludd_activated
signal turbo_fludd_activated
signal rocket_fludd_activated

var coins_collected := 0
var red_coins_collected := [0, []]
var max_red_coins := 0
var shine_shards_collected := [[0, []]]
var max_shine_shards := 0
var nozzles_collected = ["null"]
var teleporters = []
var transition_data = []
var transition_character_data = []
var transition_character_data_2 = []
var liquids = []
var liquid_positions = []
var checkpoints = []
var current_liquid_id = 0
var last_red_coin_id = 0
var switch_state : Array = []

func reload():
	coins_collected = Singleton.CheckpointSaved.current_coins
	red_coins_collected = Singleton.CheckpointSaved.current_red_coins.duplicate(true)
	shine_shards_collected = Singleton.CheckpointSaved.current_shine_shards.duplicate(true)
	nozzles_collected = Singleton.CheckpointSaved.nozzles_collected.duplicate(true)
	liquid_positions = Singleton.CheckpointSaved.liquid_positions.duplicate(true)
	switch_state = Singleton.CheckpointSaved.switch_state.duplicate(true)
	

func reset_counters():
	max_red_coins = 0
	max_shine_shards = 0
	teleporters = []
	liquids = []
	checkpoints = []
	current_liquid_id = 0
	last_red_coin_id = 0

func init():
	transition_data = []
	transition_character_data = []
	transition_character_data_2 = []

func toggle_switch_state(var channel : int):
	if !switch_state.has(channel):
		switch_state.append(channel)
	else:
		switch_state.erase(channel)
	emit_signal("switch_state_changed", channel)
	
func activate_fludd(var type : int):
	if Singleton.ModeSwitcher.get_node("ModeSwitcherButton").invisible:
		Singleton.CurrentLevelData.level_info.set_fludd_activated(type, true)		
	match(type):
		0:
			emit_signal("hover_fludd_activated")
		1:
			emit_signal("turbo_fludd_activated")
		2:
			emit_signal("rocket_fludd_activated")
			
func is_fludd_activated(var type : int):
	return Singleton.CurrentLevelData.level_info.activated_fludds[type]

#func set_switch_state(var channel : int, value : bool):
#	switch_state[channel] = value
#	emit_signal("switch_state_changed", switch_state[channel], channel)
