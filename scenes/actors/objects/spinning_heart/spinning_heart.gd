extends GameObject

const rainbow_animation_speed := 2500

onready var sprite = $Sprite
onready var color_sprite = $Color
onready var area = $Area2D
onready var sound = $AudioStreamPlayer
onready var tween = $Tween
onready var timer = $Timer
onready var anim_player = $AnimationPlayer
onready var heal_timer = $HealTimer

var color := Color(1, 0, 0)
var rainbow := false
var health_given : int = 8
var spin_time : float = 1
var heal_tick : float = 1
var cooldown := false
var cooldown_time := 0
var charbody = null

var once =  false

var on_cooldown := false
var can_heal := true
var player_speed_cap = 250

func _set_properties():
	savable_properties = ["health_given", "spin_time", "cooldown", "cooldown_time", "color", "rainbow"]
	editable_properties = ["health_given", "spin_time", "cooldown", "cooldown_time", "color", "rainbow"]
	
func _set_property_values():
	set_property("health_given", health_given, true, "Min Health / Second")
	set_property("spin_time", spin_time, true, "Heal Duration")
	set_property("cooldown", cooldown, true, "Has Cooldown?")
	set_property("cooldown_time", cooldown_time, true, "Cooldown Time")
	set_property("color", color, 1)
	set_property("rainbow", rainbow, true)

func body_enter(body):
	if body.name.begins_with("Character"):
		charbody = body
		
func body_exit(body):
	charbody = null
	once = false

func _physics_process(delta):
	if charbody != null:
		if enabled and !on_cooldown and charbody.name.begins_with("Character") and !charbody.dead:
			if cooldown:
				timer.start()
				on_cooldown = true
			var velocity = abs(charbody.velocity.x) if abs(charbody.velocity.x) > abs(charbody.velocity.y) else abs(charbody.velocity.y) 
			var heal_scale = 1 if charbody.velocity.x < player_speed_cap else clamp(charbody.velocity.x, player_speed_cap, player_speed_cap * 2) / player_speed_cap
			var spin_scale = (clamp(abs(charbody.velocity.x), 0.001, player_speed_cap) / 15) * heal_scale
			#print(heal_scale)
			if charbody.state != null && (charbody.state.name == "SpinningState" || charbody.state.name == "DiveState"):
				tween.interpolate_property(sprite, "speed_scale", 20, 1, (1 + spin_time)) #20 is 300 (player_speed_cap) divided by 15
				tween.interpolate_property(color_sprite, "speed_scale", 20, 1, (1 + spin_time))
				charbody.slow_heal(int((health_given * heal_scale) * 5), 1, spin_time, true)
				anim_player.play("hop")
				sound.play()
				tween.start()
			elif once == false:
				charbody.slow_heal(int((health_given * heal_scale) * 5), 1, spin_time, false) #Timers can't be set to zero
				tween.interpolate_property(sprite, "speed_scale", spin_scale, 1, 1 + spin_time)
				tween.interpolate_property(color_sprite, "speed_scale", spin_scale, 1, 1 + spin_time)
				once = true
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
	var _connect = area.connect("body_entered", self, "body_enter")
	var _connect2 = area.connect("body_exited", self, "body_exit")
	
func _process(delta):
	if color == Color(1, 0, 0):
		color_sprite.visible = false
	else:
		$Color.visible = true
		$Color.modulate = color
	if rainbow:
		# Hue rotation
		color.h = float(OS.get_ticks_msec() % rainbow_animation_speed) / rainbow_animation_speed
	pass

func _on_timer_timeout():
	on_cooldown = false
