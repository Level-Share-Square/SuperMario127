extends HBoxContainer

signal player_removed

onready var viewport_container1 = $ViewportContainer
onready var viewport1 = $ViewportContainer/Viewport
onready var camera1 = $ViewportContainer/Viewport/CameraP1
onready var world = $ViewportContainer/Viewport/Area
onready var player1 = $ViewportContainer/Viewport/Area/Character

export var character_scene_path : String

var player1_spawn = Vector2(0, 0)
var player2_spawn = Vector2(0, 0)

func remove_player():
	if Singleton.PlayerSettings.number_of_players == 2:
		emit_signal("player_removed")
		
		Singleton.PlayerSettings.number_of_players = 1
		player1.number_of_players = Singleton.PlayerSettings.number_of_players
		
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		
		for child in world.get_children():
			child.get_parent().remove_child(child)
			get_parent().add_child(child)
			
			if child is Character:
				get_parent().character = get_parent().get_path_to(child)
			
			if child is LevelShared:
				get_parent().shared = get_parent().get_path_to(child)
			
		for child in viewport1.get_children():
			child.get_parent().remove_child(child)
			get_parent().add_child(child)
			
			if child is Camera2D:
				get_parent().camera = get_parent().get_path_to(child)
			
		for child in viewport_container1.get_children():
			child.get_parent().remove_child(child)
			get_parent().add_child(child)
		
		queue_free()

func _ready():
	player1.character = Singleton.PlayerSettings.player1_character
	player1.number_of_players = Singleton.PlayerSettings.number_of_players
	for object in CurrentLevelData.area.get_objects_on_ground():
		if object.metadata.type_id == 0:
#			player1_spawn = object.properties[0]
			player1.spawn_pos = Vector2.ZERO
