class_name CameraCutscene
extends Resource

enum Type {AUTO, PAN, TRANSITION}

export(Type) var cutscene_type = 0 #auto, pan, transition
export(int, "Ease In", "Ease Out", "Ease In-Out", "Ease Out-In") var tween_ease = 0 # easing direction
export(int, "Linear", "Sine", "Quint", "Quart", "Quad", "Expo", "Elastic", "Cubic", "Circ", "Bounce", "Back") var transition_type = 0 # easing style
export(float) var time = 0.5 #the time it takes to pan
export(float) var max_pan_distance = 800 #how far it will pan before switching to a fade
export(bool) var do_time_scaling = true # increases the pan time dynamically based on distance
export(bool) var do_pause = true # pauses the game after the cutscene 
export(bool) var do_reverse = true # will do the cutscene again in reverse once its done 
export(bool) var lock_character_movement = true # will stop the player from moving
export(bool) var lock_camera_movement = false # will stop the camera from moving
export(bool) var from_character = false # should make the circle thing close in on the players position 
export(Array) var exclude_stoppers = [] # will ignore the passed camera stoppers during the cutscene 
export(NodePath) var owner_path # the nod etha towns the cutscene (for shine animation player stuff) 
export(String) var animation # the animation that makes said owner play 

var owner: Node
var to: Vector2 # the position the camera is going to 
var from := Vector2.INF # used to compare distance for auto cutscene type 


func set_up(owner_node: Node, new_to: Vector2, new_from: Vector2 = from):
	owner = owner_node
	to = new_to
	from = new_from
