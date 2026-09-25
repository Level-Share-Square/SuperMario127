extends CamVerticalState


const MARGIN: float = 64.0
const FULL_MARGIN: float = 192.0

const SLOW_FOLLOW_SPEED: float = 2.0
const FOLLOW_SPEED: float = 6.0
const LERP_SLOWER_SPEED: float = 12.0
const LERP_FASTER_SPEED: float = 12.0

const SPEED_THRESHOLD: float = 120.0
const MAX_SPEED: float = 500.0
const MAX_LEAD_DISTANCE: float = 280.0
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
		target_lead = MAX_LEAD_DISTANCE * speed_factor * sign(self.char_vel)
		target_lead *= self.zoom

	cur_lead_offset = lerp(cur_lead_offset, target_lead, delta * LEAD_SPEED)
	
	var diff: float = self.char_center_dist + cur_lead_offset
	var abs_diff: float = abs(diff)
	
	var zoomed_margin: float = MARGIN * self.zoom
	var zoomed_full_margin: float = FULL_MARGIN * self.zoom
	
	if abs_diff > zoomed_margin:
		var clamped_diff: float = diff - (sign(diff) * zoomed_margin)
		var follow_speed: float = FOLLOW_SPEED

		if abs_diff < zoomed_full_margin:
			var edge_ratio: float = (abs_diff - zoomed_margin) / (zoomed_full_margin - zoomed_margin)
			follow_speed = lerp(SLOW_FOLLOW_SPEED, FOLLOW_SPEED, edge_ratio)
		
		var target_pos: float = lerp(self.pos, self.pos + clamped_diff, delta * follow_speed)
		var target_vel: float = (target_pos - self.pos) / delta
		var lerp_speed: float = LERP_FASTER_SPEED if abs(target_vel) < abs(self.vel) else LERP_SLOWER_SPEED
		self.vel = lerp(self.vel, target_vel, delta * lerp_speed)
	else:
		self.vel = lerp(self.vel, 0, delta * LERP_SLOWER_SPEED)


func reset_vars() -> void:
	cur_lead_offset = 0
