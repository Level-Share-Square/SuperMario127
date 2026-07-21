extends GameObject

onready var animated_sprite = $AnimatedSprite
onready var particles = $Particles2D
onready var sound = $AudioStreamPlayer
onready var area = $Area2D
onready var animation_player = $AnimationPlayer

var collected = false
var respawn_timer = 0.0
var duration = 30.0
var can_respawn = true
var powerup_music = true

func _set_properties():
	savable_properties = ["duration", "can_respawn", "powerup_music"]
	editable_properties = ["duration", "can_respawn", "powerup_music"]

func _set_property_values():
	set_property("duration", duration, true)
	set_property("can_respawn", can_respawn, true)
	set_property("powerup_music", powerup_music, true)

func collect(body):
	if enabled and !collected and body.name.begins_with("Character") and !body.dead:
		body.heal(5 * 8)
		var powerup_node = body.get_powerup_node("WingPowerup")
		body.set_powerup(powerup_node, powerup_music, duration)
		body.sound_player.play_powerup_sound()
		body.sound_player.play_powerup_jingle()
		animation_player.play("collect")
		respawn_timer = 10.0
		collected = true
		
func _ready():
	yield(get_tree().create_timer(0.2), "timeout")
	var _connect = area.connect("body_entered", self, "collect")
	
	for body in area.get_overlapping_bodies():
			if enabled and !collected and (body and body.name.begins_with("Character") and !body.dead):
				collect(body)

func _process(delta):
	if respawn_timer > 0 and can_respawn:
		respawn_timer -= delta
		if respawn_timer <= 0:
			respawn_timer = 0
			collected = false
			animation_player.play("respawn")
