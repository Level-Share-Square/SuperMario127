extends CamState


export var follow_states: PoolStringArray

const CAM_LEAD_AMOUNT: float = 15.0
const FAST_FOLLOW_SPEED: float = 4.0
var last_char_pos: float


func start_check():
	return is_instance_valid(self.character.state) and self.character.state.name in follow_states


func stop_check():
	return not start_check()


func start() -> void:
	last_char_pos = self.char_pos


func update(delta: float) -> void:
	var target_pos: float = self.char_pos
	var movement: float = target_pos - last_char_pos
	target_pos += movement * CAM_LEAD_AMOUNT
	self.pos = lerp(self.pos, target_pos, delta * FAST_FOLLOW_SPEED)
	self.vel = 0.0
	last_char_pos = self.char_pos
