extends Control


const FAKE_PLAYER_SCENE: PackedScene = preload("res://scenes/menu/converter/minigames/fake_player.tscn")
var player: Node2D


func start_playing() -> void:
	player = FAKE_PLAYER_SCENE.instance()
	call_deferred("add_child", player)

func stop_playing(scene_name: String = "") -> void:
	if is_instance_valid(player):
		player.queue_free()
