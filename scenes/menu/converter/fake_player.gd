extends Node2D


export var player_pos: Vector2


func _ready():
	var player_char = $Character
	player_char.initial_position = player_pos
	player_char.position = player_pos
	player_char.camera = $Camera2D
	player_char.character = 0
	player_char.number_of_players = 1
	player_char.load_in()
	player_char.show()
	player_char.toggle_movement(true)
