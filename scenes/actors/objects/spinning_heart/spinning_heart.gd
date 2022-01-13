extends GameObject

onready var sprite = $Sprite
onready var area = $Area2D
onready var sound = $AudioStreamPlayer
onready var tween = $Tween
onready var timer = $Timer
onready var anim_player = $AnimationPlayer
onready var heal_timer = $HealTimer

var health_given : int = 8
var spin_time : float = 1
var heal_tick : float = 1
var cooldown := false
var cooldown_time := 0

var on_cooldown := false
var can_heal := true
var player_speed_cap = 250

func _set_properties():
	savable_properties = ["health_given", "spin_time", "cooldown", "cooldown_time"]
	editable_properties = ["health_given", "spin_time", "cooldown", "cooldown_time"]
	
func _set_property_values():
	set_property("health_given", health_given, true, "Min Health / Second")
	set_property("spin_time", spin_time, true, "Heal Duration")
	set_property("cooldown", cooldown, true, "Has Cooldown?")
	set_property("cooldown_time", cooldown_time, true, "Cooldown Time")

func collect(body):
	if enabled and !on_cooldown and body.name.begins_with("Character") and !body.dead:
		if cooldown:
			timer.start()
			on_cooldown = true
		var heal_scale = 1 if body.velocity.x < player_speed_cap else clamp(body.velocity.x, player_speed_cap, player_speed_cap * 2) / player_speed_cap
		var spin_scale = (clamp(abs(body.velocity.x), 0.001, player_speed_cap) / 15) * heal_scale
		print(heal_scale)
		if body.state != null && body.state.name == "SpinningState":
			tween.interpolate_property(sprite, "speed_scale", 20, 1, (1 + spin_time)) #20 is 300 (player_speed_cap) divided by 15
			body.slow_heal(int((health_given * heal_scale) * 5), 1, spin_time, true)
		else:
			body.slow_heal(int((health_given * heal_scale) * 5), 1, spin_time, false) #Timers can't be set to zero
			tween.interpolate_property(sprite, "speed_scale", spin_scale, 1, 1 + spin_time)
		anim_player.play("hop")
		sound.play()
		tween.start()


func _ready():
	if spin_time <= 0:
		spin_time = 1
		set_property("spin_time", spin_time, true, "Full Spin Time")
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
