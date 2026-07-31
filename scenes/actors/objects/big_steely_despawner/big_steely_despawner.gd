extends GameObject

var speed_threshold = 30
onready var steely_detector = $Area2D

#func _set_properties():
#	savable_properties = ["speed_threshold"]
#	editable_properties = ["speed_threshold"]
	
func _register_properties():
	register_property(4, "speed_threshold", speed_threshold, true)
	
func _object_ground_physics_process(delta):
	for body in steely_detector.get_overlapping_bodies():
		if body.name.begins_with("Steely"):
			var steely = body.get_parent()
			if steely.velocity.length() < speed_threshold and !steely.fade_away:
				steely.fade_away = true
				steely.shape.disabled = true
		
