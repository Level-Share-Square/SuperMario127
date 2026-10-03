extends CamState


const GROUND_OFFSET: float = -48.0
const CROUCH_OFFSET: float = 80.0

const CORRECT_SPEED: float = 3.0
const OFFSET_SPEED: float = 2.0
const AIR_OFFSET_SPEED: float = 0.5

var offset: float = 0


func start_check():
	return self.character.is_grounded()


func stop_check():
	return not start_check()


func start() -> void:
	offset = 0


func update(delta: float) -> void:
	var is_crouching: bool = self.character.inputs[character.input_names.crouch][0] and abs(self.character.velocity.x) < 10.0
	var target_offset: float = -CROUCH_OFFSET if is_crouching else -GROUND_OFFSET
	
	offset = lerp(offset, target_offset, delta * OFFSET_SPEED)
	var target_pos: float = lerp(self.pos + (offset * self.zoom), self.char_pos, delta * CORRECT_SPEED) - (offset * self.zoom)
	self.vel = (target_pos - self.pos) / delta


func general_update(delta: float) -> void:
	if self.camera.vertical_state != self:
		offset = lerp(offset, 0, delta * AIR_OFFSET_SPEED)


func reset_vars() -> void:
	offset = GROUND_OFFSET
