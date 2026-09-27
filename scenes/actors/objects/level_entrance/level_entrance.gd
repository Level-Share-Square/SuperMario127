extends Teleporter

var state_name_map: Dictionary = {
	StartState.Default: "FallState",
	StartState.Fall: "ExitPaintingState",
	StartState.Spinning: "RainbowStarState",
	StartState.Bounce: "BounceState",
	StartState.GroundPound: "GroundPoundState"
}
enum StartState {Default, Fall, Spinning, Bounce, GroundPound}

var start_state: int = StartState.Default
var start_velocity: Vector2

### PROPERTIES

func _register_properties() -> void:
	._register_properties()
	register_property(9, "start_velocity", start_velocity)
	register_property(10, "start_state", start_state)
	set_property_override("start_state", PropertyTab.OverrideTypes.ENUM, [
		"Default", "Falling", "Spinning", "Jumping", "Ground Pound"
	])

func _register_property_info() -> void:
	._register_property_info()
	set_property_info("start_velocity", PropertyInfo.new("The speed the player starts with upon entering the level", 1, -INF, INF, ["", ""], ["", ""]))
	set_property_info("start_state", PropertyInfo.new("The action the player will be performing upon entering the level.\nCan be used to create different start animations.", 1, -INF, INF, ["", ""], ["", ""]))

func _init():
	hide_teleport_properties = true
	tag = "_entrance"

func start_exit_animation(character: Character) -> void:
	.start_exit_animation(character)
	character.show()
	emit_signal("exit_completed")

func finish_exit_animation(character: Character) -> void:
	.finish_exit_animation(character)
	character.velocity = start_velocity
	character.jump_animation = 0
	character.set_state_by_name(state_name_map[start_state])
	character.velocity = start_velocity

func is_level_entrance() -> bool:
	return true
