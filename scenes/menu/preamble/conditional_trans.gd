extends Control


onready var animation_player: AnimationPlayer = $"%AnimationPlayer"

func start():
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
