extends GameObject

onready var area = $Area2D



	
func is_vanish(body):
	return body.powerup != null and body.powerup.id == "Vanish"

func kill(body):
	if !(enabled and body.name.begins_with("Character") and !body.dead and body.controllable):
		return
	
	
	
	if !is_vanish(body):
		body.knockback(global_position)
		if body.global_position.y > (global_position.y - 4):
			body.velocity.y = 55
		if !body.invulnerable:
			body.damage()
		else:
			body.sound_player.play_hit_sound()

func _ready():
	var _connect = area.connect("body_entered", self, "kill")
