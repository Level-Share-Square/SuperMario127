extends Control


onready var animation_player: AnimationPlayer = $"%AnimationPlayer"

var product = "Nintendo Switch 2"

func start():
	#:trollege:
	randomize()
	var luck = randi() % 255
	if luck == 127:
		product = [
			"Ultra Hand", "Game & Watch",
			"NES", "SNES",
			"Game Boy", "Game Boy Advance",
			"Game Boy Micro", "Game Boy Color",
			"Nintendo 64", "Nintendo Gamecube",
			"Nintendo DS", "Nintendo DSi",
			"Nintendo 3DS", "Nintendo Wii",
			"Nintendo Wii Mini", "Nintendo Wii U",
			"copy of Chibi Robo! Zip Lash",
			"copy of Mario Tennis: Ultra Smash"].pick_random()
	$"%Disclaimer".text = $"%Disclaimer".text % product
	$"%Shadow".text = $"%Shadow".text % product
	animation_player.play("show_mobile" if OS.has_feature("mobile") else "show")

func transition():
	var dir := Directory.new()
	if not Singleton.PlayerSettings.game_version_mismatch or dir.file_exists("user://level_list/converted"):
		owner.transition("MainMenu")
	else:
		var anim: Animation = animation_player.get_animation("transition")
		var track_id: int = anim.find_track(".:modulate")
		anim.track_set_enabled(track_id, false)
		
		var converter: Control = owner.get_node("../Converter")
		converter.modulate = Color.black
		var converter_anim: Animation = converter.animation_player.get_animation("transition")
		var converter_track_id: int = converter_anim.find_track(".:modulate:a")
		converter_anim.track_set_enabled(converter_track_id, false)
		
		owner.transition("Converter")
