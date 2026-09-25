extends CamVerticalState


const MARGIN: float = 64.0
const FULL_MARGIN: float = 192.0

const SLOW_FOLLOW_SPEED: float = 1.0
const FOLLOW_SPEED: float = 6.0

const SPEED_THRESHOLD: float = 120.0
const MAX_SPEED: float = 500.0
const MAX_LEAD_DISTANCE: float = 320.0
const LEAD_SPEED: float = 1.0

var cur_lead_offset: float = 0


func start_check():
	return not self.character.is_grounded()


func stop_check():
	return not start_check()


func start() -> void:
	cur_lead_offset = -self.char_center_dist


func update(delta: float) -> void:
	var target_lead: float = 0.0

	if self.char_speed > SPEED_THRESHOLD:
		var speed_factor: float = clamp((self.char_speed - SPEED_THRESHOLD) / (MAX_SPEED - SPEED_THRESHOLD), 0.0, 1.0)
		target_lead = MAX_LEAD_DISTANCE * self.zoom * speed_factor * sign(self.char_vel)

	cur_lead_offset = lerp(cur_lead_offset, target_lead, delta * LEAD_SPEED)
	
	var diff: float = self.char_center_dist + cur_lead_offset
	var abs_diff: float = abs(diff)
	if abs_diff > MARGIN * self.zoom:
		var clamped_diff: float = diff - (sign(diff) * MARGIN)
		var follow_speed: float = FOLLOW_SPEED

		if abs_diff < FULL_MARGIN:
			var edge_ratio: float = (abs_diff - MARGIN) / (FULL_MARGIN - MARGIN)
			follow_speed = lerp(SLOW_FOLLOW_SPEED, FOLLOW_SPEED, edge_ratio)
		
		self.pos = lerp(self.pos, self.pos + clamped_diff, delta * follow_speed)


func reset_vars() -> void:
	cur_lead_offset = 0
