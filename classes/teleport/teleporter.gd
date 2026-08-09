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
#func _set_properties() -> void:
#	savable_properties = ["target_area", "tag", "teleport_mode", "max_pan_distance", "level_path"]
#	editable_properties = ["target_area", "tag", "teleport_mode", "max_pan_distance", "level_path"]


func _register_properties() -> void:
	register_property(4, "target_area", target_area)
	set_property_override("target_area", PropertyTab.OverrideTypes.DROPDOWN, [CurrentLevelData, "get_area_args"])
	register_property(5, "tag", tag)
	set_property_override("tag", PropertyTab.OverrideTypes.DROPDOWN, [CurrentLevelData.level_tags, "get_teleport_args", [CurrentLevelData.level_tags, "teleport_tags"]])
	register_property(6, "teleport_mode", teleport_mode, true)
	set_property_override("teleport_mode", PropertyTab.OverrideTypes.ENUM, ["Local", "Area", "Level"] if CurrentLevelData.is_campaign else ["Local", "Area"])
	register_property(7, "max_pan_distance", max_pan_distance)
	register_property(8, "level_path", level_path, CurrentLevelData.is_campaign)


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
	set_transition_character_data(character)
	character.layer = level_layer_ref
	character.update_layer_info()
	connect("exit_completed", self, "finish_exit_animation", [character], CONNECT_ONESHOT)


## mostly just restoring control to mario
func finish_exit_animation(character: Character) -> void:
	CurrentLevelData.vars.transition_data = {}
	CurrentLevelData.vars.area_transition_helper = null
	if not character.dead:
		character.toggle_movement(true)
	character.velocity = Vector2.ZERO
	# undo collision changes 
	character.set_collision_layer_bit(1, true)
	character.set_inter_player_collision(true)

	# This is is called twice (once in start_exit_animation and
	# once here) because for some reason tint data is not
	# updated yet on start_exit_animation sooo shrug
	character.layer = level_layer_ref
	character.update_layer_info()

func set_transition_character_data(character: Character):
	var transition_character_data = CurrentLevelData.vars.transition_character_data
	
	if transition_character_data.size() > 0:
		character.health = transition_character_data[0]
		character.health_shards = transition_character_data[1]
		character.emit_signal("health_changed", character.health, character.health_shards)
		
		if transition_character_data[2] != null:
			character.set_nozzle(transition_character_data[2])
		character.fuel = transition_character_data[3]
		if transition_character_data[4][0] != null:
			var powerup_node: Powerup = character.get_powerup_node(transition_character_data[4][0])
			character.set_powerup(powerup_node, transition_character_data[4][2], transition_character_data[4][1])
		
		get_tree().get_current_scene().set_switch_timer(transition_character_data[5])

### MISC
func _ready():
	._ready()

	if "\n" in tag:
		tag = tag.replace("\n", "")
	CurrentLevelData.vars.teleporters.append([tag.to_lower(), self])

func begin_warp(character: Character) -> void:
	match teleport_mode:
		TeleportMode.Location:
			warp_helper.location_warp(character, tag, max_pan_distance)
		
		TeleportMode.Area:
			warp_helper.area_warp(character, tag, target_area)
		
		TeleportMode.Level:
			if not Singleton.ModeSwitcher.visible:
				warp_helper.level_warp(character, level_path, tag, target_area)
			else:
				warp_helper.location_warp(character, "", max_pan_distance)
