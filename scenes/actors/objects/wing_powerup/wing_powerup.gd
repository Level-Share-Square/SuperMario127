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

func _register_properties():
	register_property(4, "duration", duration)
	register_property(5, "can_respawn", can_respawn)
	register_property(6, "powerup_music", powerup_music)
	
func _register_property_info():
	set_property_info("duration", PropertyInfo.new("How long the powerup lasts in seconds.", 1, 0, INF, ["", ""], ["", ""], false, "Duration"))
	set_property_info("can_respawn", PropertyInfo.new("This will respawn 10 seconds after being collected.", 1, -INF, INF, ["", ""], ["", ""], false, "Can Respawn"))
	set_property_info("powerup_music", PropertyInfo.new("This will override the current music with powerup music.", 1, -INF, INF, ["", ""], ["", ""], false, "Powerup Music"))

func collect(body):
	if is_enabled_and_on_ground() and !collected and body.name.begins_with("Character") and !body.dead:
		body.heal(5 * 8)
		var powerup_node = body.get_powerup_node("WingPowerup")
		body.set_powerup(powerup_node, powerup_music, duration)
		if duration > 0.5:
			LastInputDevice.rumble(0.5, 0.8, 0.2)
			body.sound_player.play_powerup_sound()
			body.sound_player.play_powerup_jingle()
		animation_player.play("collect")
		respawn_timer = 10.0
		collected = true
		
func _ready():
	yield(get_tree().create_timer(0.2), "timeout")
	var _connect = area.connect("body_entered", self, "collect")
	
	for body in area.get_overlapping_bodies():
			if is_enabled_and_on_ground() and !collected and (body and body.name.begins_with("Character") and !body.dead):
				collect(body)

func _process(delta):
	if respawn_timer > 0 and can_respawn:
		respawn_timer -= delta
		if respawn_timer <= 0:
			respawn_timer = 0
			collected = false
			animation_player.play("respawn")
