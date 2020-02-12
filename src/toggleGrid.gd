extends ParallaxLayer

func _input(event):
	var globalVarsNode = get_node("../../GlobalVars");
	if globalVarsNode.gameMode == "Editing":
		if event.is_action_pressed("toggle_grid"):
			self.visible = !self.visible;
	pass
