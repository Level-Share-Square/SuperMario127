extends Control


const FAKE_PLAYER_SCENE: PackedScene = preload("res://scenes/menu/converter/minigames/fake_player.tscn")
var player: Node2D
var conversion_done: bool

func start_playing() -> void:
	if not is_instance_valid(player):
		player = FAKE_PLAYER_SCENE.instance()
		call_deferred("add_child", player)
		if conversion_done:
			player.call_deferred("emit_signal", "conversion_done")

func stop_playing(scene_name: String = "") -> void:
	if is_instance_valid(player):
		player.queue_free()

func conversion_done() -> void:
	conversion_done = true
	player.call_deferred("emit_signal", "conversion_done")
