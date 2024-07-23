extends Node

export var number_of_players = 1

export var player1_character = 0
export var player2_character = 1

export var other_player_id = -1
export var my_player_index = 0
export var connect_to_ip = "127.0.0.1"

export var keybindings : Array = SettingsSaver.get_keybindings()
export var legacy_wing_cap = false 
export var game_version = "0.8.0"
