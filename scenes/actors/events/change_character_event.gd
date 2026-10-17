extends Event
class_name ChangeCharacterEvent

var properties: Dictionary = {
	"health": 8,
	"remove_fludds": [],
	"add_fludds": []
}

var property_overrides: Dictionary = {
	"remove_fludds": [PropertyTab.OverrideTypes.MULTISELECT, ["remove_fludds", [self, "get_fludd_args"], false]],
	"add_fludds": [PropertyTab.OverrideTypes.MULTISELECT, ["add_fludds", [self, "get_fludd_args"], false]]
}

var property_info: Dictionary = {}

func get_fludd_args() -> Dictionary:
	return {
		"HoverNozzle": "Hover",
		"RocketNozzle": "Rocket",
		"TurboNozzle": "Turbo"
	}

func get_internal_name() -> String:
	return "change_character_event"

func get_display_name() -> String:
	return "Change Player"

func get_display_suffix() -> String:
	var suffix: String = " col_open%scol_close second"
	suffix = suffix.replace("col_open", COLOR_OPENING)
	suffix = suffix.replace("col_close", COLOR_CLOSING)
	return suffix

func do_event(handler: Node):
	yield(handler.get_tree(), "idle_frame")
	var character: Character = handler.get_tree().current_scene.get_node(handler.get_tree().current_scene.character)
	
	change_health(character)
	remove_nozzles(character)
	add_nozzles()
	
	.do_event(handler)
	
func remove_nozzles(character: Character) -> void:
	for nozzle in properties["remove_fludds"]:
		CurrentLevelData.vars.nozzles_collected.erase(nozzle)
		if is_instance_valid(character.nozzle) and nozzle in character.nozzle.name: character.set_nozzle("null")

func add_nozzles() -> void:
	for nozzle in properties["add_fludds"]:
		if not nozzle in CurrentLevelData.vars.nozzles_collected:
			CurrentLevelData.vars.nozzles_collected.append(nozzle)

func change_health(character: Character) -> void:
	var health_delta = properties["health"] - character.health
	if health_delta > 0:
		character.heal(health_delta)
	elif health_delta < 0:
		character.damage(abs(health_delta))
	else:
		return
