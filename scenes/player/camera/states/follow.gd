class_name CamFollowState
extends CamState


export var margin: float = 32.0
export var full_margin: float = 144.0

export var slow_follow_speed: float = 3.0
export var follow_speed: float = 6.0
export var lerp_slower_speed: float = 12.0
export var lerp_faster_speed: float = 12.0

export var speed_threshold: float = 120.0
export var max_speed: float = 500.0
export var max_lead_distance: float = 280.0
export var lead_speed: float = 1.0

var cur_lead_offset: float = 0


func start_check():
	return true


func update(delta: float) -> void:
	var target_lead: float = 0.0

	if self.char_speed > speed_threshold:
		var speed_factor: float = clamp((self.char_speed - speed_threshold) / (max_speed - speed_threshold), 0.0, 1.0)
		target_lead = max_lead_distance * speed_factor * sign(self.char_vel)
		target_lead *= self.zoom

	cur_lead_offset = lerp(cur_lead_offset, target_lead, delta * lead_speed)
	
	var diff: float = self.char_center_dist + cur_lead_offset
	var abs_diff: float = abs(diff)
	
	var zoomed_margin: float = margin * self.zoom
	var zoomed_full_margin: float = full_margin * self.zoom
	
	if abs_diff > zoomed_margin:
		var clamped_diff: float = diff - (sign(diff) * zoomed_margin)
		var working_follow_speed: float = follow_speed

		if abs_diff < zoomed_full_margin:
			var edge_ratio: float = (abs_diff - zoomed_margin) / (zoomed_full_margin - zoomed_margin)
			working_follow_speed = lerp(slow_follow_speed, follow_speed, edge_ratio)
		
		var target_pos: float = lerp(self.pos, self.pos + clamped_diff, delta * follow_speed)
		var target_vel: float = (target_pos - self.pos) / delta
		var lerp_speed: float = lerp_faster_speed if abs(target_vel) < abs(self.vel) else lerp_slower_speed
		self.vel = lerp(self.vel, target_vel, delta * lerp_speed)
	else:
		self.vel = lerp(self.vel, 0, delta * lerp_slower_speed)


func reset_vars() -> void:
	cur_lead_offset = 0
