extends TouchCheck



func _input(_event):
	if is_instance_valid(character): return
	._check()
	if not character.is_connected("nozzle_changed", self, "nozzle_changed"):
		character.connect("nozzle_changed", self, "nozzle_changed")


func nozzle_changed(new_nozzle: String):
	print(new_nozzle)
	get_parent().visible = (new_nozzle != "null")
