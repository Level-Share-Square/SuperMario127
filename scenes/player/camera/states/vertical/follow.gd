extends CamFollowState


export var follow_states: PoolStringArray


func start_check():
	return is_instance_valid(self.character.state) and self.character.state.name in follow_states


func stop_check():
	return not start_check()
