extends Node

class_name BusGroup

# ======================================
# | This class was created to mitigate |
# | some of the messy code that was    |
# | in sounds.gd as of commit 2a4a272. |
# |                                    |
# | This class is meant to group       |
# | SoundGroups together into a        |
# | package that can be easily swapped |
# | between effects buses.             |
# ======================================

var container := []
var current_bus := "Master"
func _ready():
	for i in get_children():    #This retrieves all of the SoundGroup children in this BusGroup
		var j = i as SoundGroup #This sets j to null if it is not a SoundGroup
		if j == null:
			push_warning("\'%s\' is not a SoundGroup. Skipping...") % i.name
			pass                #If j is null, move to the next child
		else: 
			container.append(i) #Otherwise, add it to the list

func set_bus(bus: String):
	for i in container:
		i.bus = bus
	current_bus = bus
func get_bus():
	return current_bus
