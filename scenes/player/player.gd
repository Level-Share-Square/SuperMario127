extends LevelDataLoader

export var character : NodePath
export var character2 : NodePath
export var camera : NodePath

var mode = 0

export var coin_frame : int
const coin_anim_fps = 12
var can_collect_coins : Array

export var switch_timer : float = 0.0

func _process(_delta):
	coin_frame = (OS.get_ticks_msec() * coin_anim_fps / 1000) % 4

func _physics_process(delta):
	if switch_timer > 0:
		switch_timer -= delta
		if switch_timer <= 0:
			switch_timer = 0

func _ready():
	CurrentLevelData.level_data.vars.reset_counters()
	
	if !MiscShared.is_play_reload:
		CheckpointSaved.reset()
		CurrentLevelData.level_data.vars.init()
	
	if CurrentLevelData.level_data.vars.transition_data == []:
		CurrentLevelData.area = CheckpointSaved.current_area
		CurrentLevelData.level_data.vars.reload()
	
	var data = CurrentLevelData.level_data
	load_in(data, data.areas[CurrentLevelData.area])
	
	music.character = get_node(character)
	music.character2 = get_node(character2)
	if !music.playing:
		music.play() # make sure the music will play even if it's stopped prior to loading the player

	can_collect_coins.append(get_node(character))
	if PlayerSettings.number_of_players == 2:
		can_collect_coins.append(get_node(character2))

	if PlayerSettings.other_player_id != -1:
		if PlayerSettings.my_player_index == 0:
			get_node(character).set_network_master(get_tree().get_network_unique_id())
			get_node(character).controlled_locally = true
			get_node(character2).set_network_master(PlayerSettings.other_player_id)
			get_node(character2).controlled_locally = false
		else:
			get_node(character2).set_network_master(get_tree().get_network_unique_id())
			get_node(character2).controlled_locally = true
			get_node(character).set_network_master(PlayerSettings.other_player_id)
			get_node(character).controlled_locally = false
			get_node(camera).character_node = get_node(character2)
		
	CurrentLevelData.level_data.vars.max_red_coins = 0
	CurrentLevelData.level_data.vars.max_shine_shards = 0
	CurrentLevelData.level_data.vars.doors = []
	CurrentLevelData.level_data.vars.pipes = []
	CurrentLevelData.level_data.vars.liquids = []
	CurrentLevelData.level_data.vars.checkpoints = []

	if mode_switcher.get_node("ModeSwitcherButton").invisible and CheckpointSaved.current_checkpoint_id == -1:
		CurrentLevelData.start_tracking_time_score()
	
	MiscShared.is_play_reload = true

	yield(get_tree(), "physics_frame")
	CurrentLevelData.level_data.vars.max_red_coins = CurrentLevelData.get_red_coins_before_area(CurrentLevelData.level_data.areas.size())

func _unhandled_input(event):
	if event.is_action_pressed("reload") or event.is_action_pressed("reload_from_start") and !scene_transitions.transitioning and (!mode_switcher.get_node("ModeSwitcherButton").switching_disabled or mode_switcher.get_node("ModeSwitcherButton").invisible):
		if event.is_action_pressed("reload_from_start"):
			CheckpointSaved.reset()
		if !get_node(character).dead:
			get_node(character).kill("reload")
		elif PlayerSettings.number_of_players == 2:
			get_node(character2).kill("reload")
		if PlayerSettings.other_player_id != -1:
			var _send_bytes = get_tree().multiplayer.send_bytes(JSON.print(["reload"]).to_ascii())

func switch_scenes():
	var _change_scene = get_tree().change_scene("res://scenes/editor/editor.tscn")

func reload_scene():
	var _reload = get_tree().reload_current_scene()
