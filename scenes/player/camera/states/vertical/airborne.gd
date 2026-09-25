extends CamFollowState


func start_check():
	return not self.character.is_grounded()


func stop_check():
	return not start_check()


func start() -> void:
	cur_lead_offset = -self.char_center_dist
