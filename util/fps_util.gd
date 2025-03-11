class_name fps_util

const PHYSICS_DELTA = 0.01659722222


static func _update_framerate(change_framerate : bool = true):
	# stole this from the godot docs, should work like a charm to
	# not unnecessarily have the framerate absurdly high though
	var refresh_rate = OS.get_screen_refresh_rate()
	if refresh_rate < 0:
		refresh_rate = 60.0
	
	if change_framerate:
		Engine.set_target_fps(refresh_rate)
	
	#this was in lss_ping.gd... for some reason. well now at least it's not being called every physics tick
	OS.set_window_title("Super Mario 127 (FPS: " + str(Engine.get_frames_per_second()) + ")")
