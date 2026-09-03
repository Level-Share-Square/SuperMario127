extends GameObject

onready var area = $Area2D
onready var area_shape = $Area2D/CollisionShape2D
onready var sprite = $AnimatedSprite
onready var sprite_1 = $AnimatedSprite/Color1
onready var sprite_2 = $AnimatedSprite/Color2
onready var flame_sound = $Flame
onready var flame_volume: float = flame_sound.volume_db
onready var sound_tween = $SoundTween

var retracted_time = 2.5
var burning_time = 2.5
var offset = 0.0
var color = Color(1, 0, 0)

var next_state_timer: float = 0
var burning = true
var reversed = false

#func _set_properties():
#	savable_properties = ["retracted_time", "burning_time", "color", "reversed", "offset"]
#	editable_properties = ["retracted_time", "burning_time", "color", "reversed", "offset"]

func _register_properties():
	register_property(4, "retracted_time", retracted_time, true)
	register_property(5, "burning_time", burning_time, true)
	register_property(6, "color", color, true)
	register_property(7, "reversed", reversed, true)
	register_property(8, "offset", offset, true)

func _object_ready():
	flame_sound.volume_db = -80
	
	burning = !reversed
	next_state_timer = burning_time if !reversed else retracted_time
	
	next_state_timer += offset
	
	area.connect("body_entered", self, "burn_player")

func _object_physics_process(delta):
	if mode == 1:
		return
	
	if next_state_timer > 0:
		next_state_timer -= delta
		if next_state_timer <= 0:
			next_state_timer = retracted_time if burning else burning_time
			burning = !burning
			sound_tween.stop_all()
			sound_tween.interpolate_property(flame_sound, "volume_db",
				flame_sound.volume_db,
				flame_volume if burning else -80,
				1.0, 
				Tween.TRANS_QUAD,
				Tween.EASE_OUT
			)
			sound_tween.start()
	
	area_shape.disabled = !burning or !is_enabled_and_on_ground()
	
	if burning:
		sprite.position = lerp(sprite.position, Vector2(0, 0), delta * 8)
		sprite.scale = lerp(sprite.scale, Vector2(1, 1), delta * 8)
	else:
		sprite.position = lerp(sprite.position, Vector2(0, 48), delta * 8)
		sprite.scale = lerp(sprite.scale, Vector2(0, 0), delta * 8)
	sprite.reset_physics_interpolation()

func _process(_delta):
	if color == Color(1, 0, 0):
		sprite.self_modulate = Color(1, 1, 1)
		sprite_1.visible = false
		sprite_2.visible = false
	else:
		var color_0 = color
		var color_1 = color
		
		color_0.s /= 4
		color_1.s /= 2
		
		sprite.self_modulate = color_0
		sprite_1.self_modulate = color_1
		sprite_2.self_modulate = color
		sprite_1.visible = true
		sprite_2.visible = true

func burn_player(body):
	#putting this here instead of the lava boost state or mario.gd 
	#bc I don't know how to do it better frankly
	if body is Character:
		if body.powerup != body.get_powerup_node("MetalPowerup") and body.powerup != body.get_powerup_node("RainbowPowerup"):
			body.set_state_by_name("LavaBoostState", get_physics_process_delta_time())
			body.velocity.y = -body.get_state_node("LavaBoostState").boost_velocity
