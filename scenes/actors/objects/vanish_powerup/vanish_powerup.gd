extends GameObject

onready var animated_sprite = $AnimatedSprite
onready var sound = $AudioStreamPlayer
onready var area = $Area2D
onready var visibility_enabler = $VisibilityEnabler2D

var collected = false
var respawn_timer = 0.0
var duration = 30.0
var can_respawn = true

export var anim_damp = 80

func _set_properties():
	savable_properties = ["duration", "can_respawn"]
	editable_properties = ["duration", "can_respawn"]
	
func _set_property_values():
	set_property("duration", duration, true)
	set_property("can_respawn", can_respawn, true)

func collect(body):
	if enabled and !collected and body.name.begins_with("Character") and !body.dead:
		body.heal(5 * 8)
		var powerup_node = body.get_powerup_node("VanishPowerup")
		powerup_node.time_left = duration
		body.set_powerup(powerup_node)
		respawn_timer = 10.0
		collected = true
		
func _ready():
	yield(get_tree().create_timer(0.2), "timeout")
	var _connect = area.connect("body_entered", self, "collect")

func _process(delta):
	animated_sprite.visible = !collected
	if respawn_timer > 0 and can_respawn:
		respawn_timer -= delta
		if respawn_timer <= 0:
			respawn_timer = 0
			collected = false
			animated_sprite.visible = true
	if !collected:
		animated_sprite.frame = (OS.get_ticks_msec() / anim_damp) % 4
