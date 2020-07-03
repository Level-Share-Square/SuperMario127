extends LevelDataLoader

export var character : NodePath
export var character2 : NodePath

export var camera : NodePath

var mode = 0

func _ready():
	var data = CurrentLevelData.level_data
	load_in(data, data.areas[CurrentLevelData.area])
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
	
func _unhandled_input(event):
	if event.is_action_pressed("reload") and !scene_transitions.transitioning and !mode_switcher.get_node("ModeSwitcherButton").switching_disabled:
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
