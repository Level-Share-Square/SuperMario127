extends Node


# This script exists for the sole purpose of removing the filtering from
# the GradientTexture2Ds used on torches, because it's broken and probably will 
# never be fixed in Godot 3.

export(Array, Texture) var textures = []


# Called when the node enters the scene tree for the first time.
func _ready():
	for tex in textures:
		fix_flags(tex)


func fix_flags(tex: Texture):
	# save intended_value
	var aux_flags = 3
	# change it to force an update, otherwise it is ignored
	tex.flags = 0
	yield(get_tree(),"idle_frame")
	tex.flags = aux_flags
	
#	print(tex.flags)
