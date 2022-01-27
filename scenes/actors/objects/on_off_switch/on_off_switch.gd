extends Block

onready var sprite = $AnimatedSprite
onready var block = $StaticBody2D
onready var hit_collider = $HitCollider
onready var switch_sound = $SwitchSound
onready var curve_tween = $AnimatedSprite/CurveTween

export(Array, SpriteFrames) var palette_frames

func _ready():
	init()
	if is_preview:
		z_index = 0
		sprite.z_index = 0

	if !enabled:
		$StaticBody2D.set_collision_layer_bit(0, false)

	if palette != 0:
		sprite.frames = palette_frames[palette - 1]
	
	_connect()

	sprite.frame = int(Singleton.CurrentLevelData.switch_state[palette])

func _connect():
	curve_tween.connect("curve_tween", self, "_on_curve_tween")
	Singleton.CurrentLevelData.connect("switch_state_changed", self, "_on_switch_state_changed")
	hit_collider.connect("body_entered", self, "_on_hit_body_entered")
	hit_collider.connect("area_entered", self, "_on_hit_area_entered")

func _start_hit_anim(direction):
	curve_tween.play(0.1, Vector2.ZERO, direction * Vector2(14, 14))

func _on_switch_state_changed(new_state, channel):
	if palette == channel:
		sprite.frame = int(new_state)

func _on_hit():
	switch_sound.play()
	Singleton.CurrentLevelData.toggle_switch_state(palette)

func _on_curve_tween(value):
	sprite.position = value
