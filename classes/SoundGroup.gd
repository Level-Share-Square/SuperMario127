extends "res://addons/mixing-desk/sound/nonspatial/ran_cont.gd"

class_name SoundGroup

# ======================================
# | This class was created to mitigate |
# | some of the messy code that was    |
# | in sounds.gd as of commit 2a4a272. |
# |                                    |
# | This class is meant to group audio |
# | streams together into a package    |
# | that can be easily swapped between |
# | BusGroups or effects busses.       |
# ======================================

# ran_cont.gd in addons/mixing-desk/nonspatial already does most of the heavy lifting.
# This is here to just make sure there's no type confusion in BusGroup..

func _ready():
	pass

