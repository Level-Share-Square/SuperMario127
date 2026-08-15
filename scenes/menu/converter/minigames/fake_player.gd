extends Node2D


export var player_pos: Vector2
signal conversion_done


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


func open_settings():
	var parent_screen: Control = get_parent().owner
	parent_screen.modulate = Color.white
	var anim: Animation = parent_screen.animation_player.get_animation("transition")
	var track_id: int = anim.find_track(".:modulate:a")
	anim.track_set_enabled(track_id, false)
	
	var options: Control = parent_screen.get_node("../Options")
	options.get_node("Black").show()
	options.get_node("ExitController").target_screen = parent_screen.name
	parent_screen.transition("Options")


func restart_game():
	OS.execute(OS.get_executable_path(), PoolStringArray(), false)
	get_tree().quit()
