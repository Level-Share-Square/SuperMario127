class_name Teleporter
extends GameObject


signal entrance_completed
signal exit_completed

enum TeleportMode {Location, Area, Level}

onready var warp_helper = $"%WarpHelper"
var teleporter: Teleporter
var timer_manager

var target_area := -1
var tag: String = "default_teleporter"
var teleport_mode: int = TeleportMode.Location
var max_pan_distance: int = 800
var level_path: String = ""


### PROPERTIES
func _set_properties() -> void:
	savable_properties = ["target_area", "tag", "teleport_mode", "max_pan_distance", "level_path"]
	editable_properties = ["target_area", "tag", "teleport_mode", "max_pan_distance", "level_path"]


func _set_property_values() -> void:
	set_property("target_area", target_area)
	set_property("tag", tag)
	set_property("teleport_mode", teleport_mode, true)
	set_property_menu("teleport_mode", ["option", 3, 0, ["Location", "Area", "Level"]])
	set_bool_alias("teleportation_mode", "Remote", "Local")
	set_property("max_pan_distance", max_pan_distance)
	set_property("level_path", level_path)


### ANIMATION
func start_entrance_animation(character: Character) -> void:
	character.set_dive_collision(false)
	character.toggle_movement(false)
	character.velocity = Vector2.ZERO
	character.sprite.rotation = 0
	# disable collisions w/ most things
	character.set_collision_layer_bit(1, false)
	character.set_inter_player_collision(false)
	
	connect("entrance_completed", self, "begin_warp", [character], CONNECT_ONESHOT)


func start_exit_animation(character: Character) -> void:
	connect("exit_completed", self, "finish_exit_animation", [character], CONNECT_ONESHOT)


## mostly just restoring control to mario
func finish_exit_animation(character: Character) -> void:
	Singleton.CurrentLevelData.level_data.vars.transition_data = {}
	Singleton.CurrentLevelData.level_data.vars.area_transition_helper = null
	if not character.dead:
		character.toggle_movement(true)
	character.velocity = Vector2.ZERO
	# undo collision changes 
	character.set_collision_layer_bit(1, true)
	character.set_inter_player_collision(true)


### MISC
func _ready():
	Singleton.CurrentLevelData.level_data.vars.teleporters.append([tag.to_lower(), self])
	if "\n" in tag:
		tag = tag.replace("\n", "")


func begin_warp(character: Character) -> void:
	match teleport_mode:
		TeleportMode.Location:
			warp_helper.location_warp(character, tag, max_pan_distance)
		
		TeleportMode.Area:
#			print(target_area)
			warp_helper.area_warp(character, tag, target_area)
		
		TeleportMode.Level:
			if Singleton.ModeSwitcher.get_node("ModeSwitcherButton").invisible:
				warp_helper.level_warp(character, level_path, tag, target_area)
			else:
				warp_helper.location_warp(character, "", max_pan_distance)
