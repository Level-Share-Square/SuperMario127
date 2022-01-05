extends GameObject

onready var sprite = $Sprite
onready var area = $Area2D
onready var sound = $AudioStreamPlayer
onready var tween = $Tween
onready var timer = $Timer
onready var anim_player = $AnimationPlayer
onready var heal_timer = $HealTimer

var max_health_given : int = 4
var cooldown := false
var cooldown_time := 0

var on_cooldown := false
var can_heal := true
var player_speed_cap = 300

func _set_properties():
	savable_properties = ["max_health_given", "cooldown", "cooldown_time"]
	editable_properties = ["max_health_given", "cooldown", "cooldown_time"]
	
func _set_property_values():
	set_property("max_health_given", max_health_given, true)
	set_property("cooldown", cooldown, true, "Has Cooldown?")
	set_property("cooldown_time", cooldown_time, true, "Cooldown Time")

func collect(body):
	if enabled and !on_cooldown and body.name.begins_with("Character") and !body.dead:
		if cooldown:
			timer.start()
			on_cooldown = true
		var spin_scale = clamp(abs(body.velocity.x), 0, player_speed_cap) / 15
		if body.state != null && body.state.name == "SpinningState":
			tween.interpolate_property(sprite, "speed_scale", 20, 1, 2) #20 is 300 (player_speed_cap) divided by 15
			body.slow_heal(max_health_given * 8, 1)
		else:
			var health_step = player_speed_cap / max_health_given
			var time_step = player_speed_cap / 3
			var health_given = stepify(clamp(abs(body.velocity.x), health_step, player_speed_cap), health_step) / health_step
			var time_delay = stepify(clamp(abs(body.velocity.x), time_step, player_speed_cap), time_step) / time_step
			body.slow_heal(int(health_given), time_delay)
			tween.interpolate_property(sprite, "speed_scale", spin_scale, 1, 2)
		anim_player.play("hop")
		sound.play()
		tween.start()

func _ready():
	timer.wait_time = cooldown_time
	timer.connect("timeout", self, "_on_timer_timeout")
	if is_preview:
		z_index = 0
		sprite.z_index = 0
	var _connect = area.connect("body_entered", self, "collect")
	
func _process(delta):
	pass

func _on_timer_timeout():
	on_cooldown = false
