extends GameObject

onready var animated_sprite = $AnimatedSprite
onready var sound = $AudioStreamPlayer
onready var area = $Area2D
onready var visibility_enabler = $VisibilityEnabler2D

var collected = false
var respawn_timer = 0.0
var duration = 30.0

export var anim_damp = 80

func _set_properties():
	savable_properties = ["duration"]
	editable_properties = ["duration"]
	
func _set_property_values():
	set_property("duration", duration, true)

func collect(body):
	if enabled and !collected and body.name.begins_with("Character") and !body.dead:
		body.heal(5 * 8)
		var powerup_node = body.get_powerup_node("MetalPowerup")
		powerup_node.time_left = duration
		body.powerup = powerup_node
		respawn_timer = 10.0
		animated_sprite.visible = false
		
func _ready():
	yield(get_tree().create_timer(0.2), "timeout")
	var _connect = area.connect("body_entered", self, "collect")

func _process(delta):
	if respawn_timer > 0:
		respawn_timer -= delta
		if respawn_timer <= 0:
			respawn_timer = 0
			collected = false
			animated_sprite.visible = true
	if !collected:
		animated_sprite.frame = (OS.get_ticks_msec() / anim_damp) % 4
