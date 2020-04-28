extends HBoxContainer

onready var viewport_container1 = $ViewportContainer
onready var viewport_container2 = $ViewportContainer2

onready var viewport1 = $ViewportContainer/Viewport
onready var viewport2 = $ViewportContainer2/Viewport

onready var camera1 = $ViewportContainer/Viewport/CameraP1
onready var camera2 = $ViewportContainer2/Viewport/CameraP2

onready var player1 = $ViewportContainer/Viewport/World/Character
onready var player2 = $ViewportContainer/Viewport/World/Character2

export var divider_path : NodePath
onready var divider = get_node(divider_path)

export var character_scene_path : String

var last_player1_dead = false
var last_player2_dead = false

var player1_spawn = Vector2(0, 0)
var player2_spawn = Vector2(0, 0)

func remove_player():
	if PlayerSettings.number_of_players == 2:
		player2.position.y = 9999999999999
		viewport_container2.visible = false
		camera2.character_node = null
		player2.queue_free()
		PlayerSettings.number_of_players = 1
		player1.number_of_players = PlayerSettings.number_of_players

func add_player(): # boy do i love hacks
	if PlayerSettings.number_of_players == 1:
		PlayerSettings.number_of_players = 2
		player2 = load(character_scene_path).instance()
		player2.character = PlayerSettings.player2_character
		player2.player_id = 1
		player2.name = "Character2"
		player2.add_collision_exception_with(player1)
		player1.add_collision_exception_with(player2)
		player1.number_of_players = PlayerSettings.number_of_players
		player2.number_of_players = PlayerSettings.number_of_players
		viewport1.add_child(player2)
		player2._ready()
		player2.load_in(CurrentLevelData.level_data, CurrentLevelData.level_data.areas[CurrentLevelData.area])
		camera2.character_node = player2
		player2.position = player2_spawn
		player2.spawn_pos = player2_spawn
		
		viewport_container1.visible = true
		viewport_container2.visible = true
		viewport2.size.x = 384
		viewport_container2.rect_size.x = 384
		viewport1.size.x = 384
		viewport_container1.rect_size.x = 384
		
		camera1.smoothing_enabled = false
		camera2.smoothing_enabled = false
		yield(get_tree(),"idle_frame")
		camera1.smoothing_enabled = true
		camera2.smoothing_enabled = true

func _ready():
	player1.character = PlayerSettings.player1_character
	player2.character = PlayerSettings.player2_character
	viewport2.world_2d = viewport1.world_2d
	player1.number_of_players = PlayerSettings.number_of_players
	player2.number_of_players = PlayerSettings.number_of_players
	for object in CurrentLevelData.level_data.areas[CurrentLevelData.area].objects:
		if object.type_id == 0:
			player1_spawn = object.properties[0]
		elif object.type_id == 5:
			player2_spawn = object.properties[0]
	if PlayerSettings.number_of_players == 1:
		PlayerSettings.number_of_players = 2
		remove_player()

func _process(_delta):
	if PlayerSettings.number_of_players == 2 and PlayerSettings.other_player_id == -1:
		if Input.is_action_just_pressed("(disabled)copy_level"):
			remove_player()
		if player2.dead:
			viewport_container2.visible = false
			viewport_container1.visible = true
			viewport1.size.x = 768
			viewport_container1.rect_size.x = 768
			viewport2.size.x = 0
			viewport_container2.rect_size.x = 0
			if !last_player2_dead:
				camera1.smoothing_enabled = false
				yield(get_tree(),"idle_frame")
				camera1.smoothing_enabled = true
			
		if player1.dead:
			viewport_container1.visible = false
			viewport_container2.visible = true
			viewport2.size.x = 768
			viewport_container2.rect_size.x = 768
			viewport1.size.x = 0
			viewport_container1.rect_size.x = 0
			if !last_player1_dead:
				camera2.smoothing_enabled = false
				yield(get_tree(),"idle_frame")
				camera2.smoothing_enabled = true
			
		if !player2.dead and !player1.dead:
			viewport_container1.visible = true
			viewport_container2.visible = true
			viewport2.size.x = 384
			viewport_container2.rect_size.x = 384
			viewport1.size.x = 384
			viewport_container1.rect_size.x = 384
			if last_player1_dead or last_player2_dead:
				camera1.smoothing_enabled = false
				camera2.smoothing_enabled = false
				yield(get_tree(),"idle_frame")
				camera1.smoothing_enabled = true
				camera2.smoothing_enabled = true

		if player1.dead or player2.dead:
			divider.visible = false
		else:
			divider.visible = true
			
		last_player1_dead = player1.dead
		last_player2_dead = player2.dead
		
		player1.controlled_locally = true
		player2.controlled_locally = true
	else:
		viewport_container2.visible = false
		viewport_container1.visible = true
		viewport1.size.x = 768
		viewport_container1.rect_size.x = 768
		viewport2.size.x = 0
		viewport_container2.rect_size.x = 0
		
		divider.visible = false
		if Input.is_action_just_pressed("(disabled)paste_level"):
			add_player()
