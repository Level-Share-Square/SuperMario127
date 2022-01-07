extends GameObject

onready var sprite = $Sprite
onready var area = $Area2D
onready var sound = $AudioStreamPlayer
onready var tween = $Tween
onready var timer = $Timer
onready var anim_player = $AnimationPlayer
onready var heal_timer = $HealTimer

var health_given : int = 8
var regeneration_time : float = 1
var heal_tick : float = 1
var cooldown := false
var cooldown_time := 0

var on_cooldown := false
var can_heal := true
var player_speed_cap = 300

func _set_properties():
	savable_properties = ["health_given", "cooldown", "cooldown_time",  "heal_tick", "regeneration_time"]
	editable_properties = ["health_given", "cooldown", "cooldown_time", "heal_tick", "regeneration_time"]
	
func _set_property_values():
	set_property("health_given", health_given, true)
	set_property("cooldown", cooldown, true, "Has Cooldown?")
	set_property("cooldown_time", cooldown_time, true, "Cooldown Time")
	set_property("heal_tick", heal_tick, true)
	set_property("regeneration_time", regeneration_time, true)

func collect(body):
	if enabled and !on_cooldown and body.name.begins_with("Character") and !body.dead:
		if cooldown:
			timer.start()
			on_cooldown = true
		var spin_scale = clamp(abs(body.velocity.x), 0, player_speed_cap) / 15

		if body.velocity.x >= player_speed_cap || (body.state != null && body.state.name == "SpinningState"):
			tween.interpolate_property(sprite, "speed_scale", 20, 1, (2 + regeneration_time)) #20 is 300 (player_speed_cap) divided by 15
			body.slow_heal(int((health_given * 1.25) * 5), heal_tick, regeneration_time)
		else:
			body.slow_heal(int(health_given * 5), 1, 0) #regen timer can't be 0
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
