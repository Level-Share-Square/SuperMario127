class_name LevelVars

signal switch_state_changed

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
var switch_state : Array = [true, true, true, true, true, true, true]

func reload():
	coins_collected = Singleton.CheckpointSaved.current_coins
	red_coins_collected = Singleton.CheckpointSaved.current_red_coins.duplicate(true)
	shine_shards_collected = Singleton.CheckpointSaved.current_shine_shards.duplicate(true)
	nozzles_collected = Singleton.CheckpointSaved.nozzles_collected.duplicate(true)
	liquid_positions = Singleton.CheckpointSaved.liquid_positions.duplicate(true)
	switch_state = [true, true, true, true, true, true, true]

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
	switch_state[channel] = !switch_state[channel]
	emit_signal("switch_state_changed", switch_state[channel], channel)

func set_switch_state(var channel : int, value : bool):
	switch_state[channel] = value
	emit_signal("switch_state_changed", switch_state[channel], channel)
