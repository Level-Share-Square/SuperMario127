class_name fps_util

const PHYSICS_DELTA = 0.01659722222


static func _update_framerate(_change_framerate : bool = false):
	#this was in lss_ping.gd... for some reason. well now at least it's not being called every physics tick
	OS.set_window_title("Super Mario 127 (FPS: " + str(Engine.get_frames_per_second()) + ")")
