extends CanvasLayer

onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var sparkle_sound: AudioStreamPlayer = $Sparkle

func start_scene_change(new_scene: PackedScene, in_anim: String, out_anim: String):
	animation_player.play_backwards(in_anim + "_transition")
	animation_player.connect("animation_finished", self, "end_scene_change", [new_scene, out_anim], CONNECT_ONESHOT)

func end_scene_change(animation_name: String, new_scene: PackedScene, out_anim: String):
	get_tree().change_scene_to(new_scene)
	animation_player.play(out_anim + "_transition")


func start_level(level_data: LevelData):
	sparkle_sound.play()
	
	var player_scene: PackedScene = load("res://scenes/player/player.tscn")
	start_scene_change(player_scene, "fade", "fade")

func is_busy():
	return animation_player.is_playing()
