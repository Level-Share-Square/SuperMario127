extends LevelDataLoader

export var character : NodePath
export var character2 : NodePath
export var camera : NodePath

var mode = 0

export var coin_frame : int
const coin_anim_fps = 12
var can_collect_coins : Array

func _process(_delta):
	coin_frame = (OS.get_ticks_msec() * coin_anim_fps / 1000) % 4

var rainbow_gradient_texture = GradientTexture.new()
var rainbow_gradient = Gradient.new()
var rainbow_hue = 0

func _physics_process(delta):
	rainbow_hue += 0.0075 * delta * 120
	rainbow_gradient.offsets = PoolRealArray([0.15, 1])
	rainbow_gradient.colors = PoolColorArray([Color.from_hsv(rainbow_hue, 1, 1), Color(1, 1, 1)])
	rainbow_gradient_texture.gradient = rainbow_gradient

func _ready():
	NotificationHandler.success("Game loaded", "I eat raw steak")
	NotificationHandler.warning("Game loaded", "Yeah, I already know...")
	NotificationHandler.warning("Game loaded... again", "Yeah, we did it, bois!")
	
	var data = CurrentLevelData.level_data
	load_in(data, data.areas[CurrentLevelData.area])
	music.character = get_node(character)
	music.character2 = get_node(character2)

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
