class_name LevelVars

var coins_collected := 0
var red_coins_collected := [0, []]
var max_red_coins := 0
var shine_shards_collected := [[0, []]]
var max_shine_shards := 0
var nozzles_collected = ["null"]
var teleporters = [] #Unused for now...
var doors = [] #Soon becoming deprecated...
var pipes = [] #Soon becoming deprecated...
var transition_data = []
var transition_character_data = []
var transition_character_data_2 = []
var liquids = []
var liquid_positions = []
var checkpoints = []
var current_liquid_id = 0
var last_red_coin_id = 0

func reload():
	coins_collected = Singleton.CheckpointSaved.current_coins
	red_coins_collected = Singleton.CheckpointSaved.current_red_coins.duplicate(true)
	shine_shards_collected = Singleton.CheckpointSaved.current_shine_shards.duplicate(true)
	nozzles_collected = Singleton.CheckpointSaved.nozzles_collected.duplicate(true)
	liquid_positions = Singleton.CheckpointSaved.liquid_positions.duplicate(true)

func reset_counters():
	max_red_coins = 0
	max_shine_shards = 0
	doors = []
	pipes = []
	liquids = []
	checkpoints = []
	current_liquid_id = 0
	last_red_coin_id = 0

func init():
	transition_data = []
	transition_character_data = []
	transition_character_data_2 = []
