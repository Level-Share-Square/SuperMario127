extends Block

onready var sprite = $Sprite
onready var block = $StaticBody2D
onready var hit_collider = $HitCollider
onready var curve_tween = $Sprite/CurveTween


func _ready():
	
	init()
	if is_preview:
		z_index = 0
		sprite.z_index = 0
		
#	if mode == 1:
#			register_property("default_state", default_state, true)
#
	sprite.region_rect.position.x = int(!CurrentLevelData.vars.switch_state.has(palette)) * 32

	sprite.region_rect.position.y = palette * 32
	
func _object_ready():
	._object_ready()
	if is_enabled_and_on_ground():
		_connect()
	else:
		$StaticBody2D.set_collision_layer_bit(0, false)

func _connect():
	curve_tween.connect("curve_tween", self, "_on_curve_tween")
	CurrentLevelData.vars.connect("switch_state_changed", self, "_on_switch_state_changed")
	if mode != 1:
		hit_collider.connect("body_entered", self, "_on_hit_body_entered")
		hit_collider.connect("area_entered", self, "_on_hit_area_entered")

func _start_hit_anim(direction):
	curve_tween.play(0.1, Vector2.ZERO, direction * Vector2(14, 14))

func _on_switch_state_changed(channel):
	if palette == channel:
		
		if sprite.region_rect.position.x == 32: #int(true) * 32
			sprite.region_rect.position.x = 0
		else:
			sprite.region_rect.position.x = 32

func _on_hit():
	var sound_name = "SwitchOffSound"
	if palette in CurrentLevelData.vars.switch_state:
		sound_name = "SwitchOnSound"
	#play_shared_sound(sound_name)
	
	CurrentLevelData.vars.toggle_switch_state(palette)

func _on_curve_tween(value):
	sprite.position = value
	sprite.reset_physics_interpolation()
