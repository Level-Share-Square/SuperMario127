extends GameObject

onready var area = $Area2D
onready var sprite = $AnimatedSprite
onready var animation_player = $AnimationPlayer
onready var delete_timer = $DeleteTimer

var dead
	
func is_vanish(body):
	return body.powerup != null and body.powerup.id == "Vanish"

func kill(body):
	if dead or !(enabled and body.name.begins_with("Character") and !body.dead and body.controllable):
		return
	
	if body.invincible:
		dead = true
		animation_player.play("die")
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
	var _connect2 = delete_timer.connect("timeout", self, "queue_free")
