extends Block

onready var sprite = $Sprite
onready var block = $StaticBody2D
onready var hit_collider = $HitCollider
onready var switch_sound = $SwitchSound
onready var curve_tween = $Sprite/CurveTween

func _set_properties():
	savable_properties = ["palette"]
	editable_properties = ["palette"]

func _set_property_values():
	set_property("palette", palette, 0)


func _ready():
	
	init()
	if is_preview:
		z_index = 0
		sprite.z_index = 0
		
#	if mode == 1:
#			set_property("default_state", default_state, true)
#
	sprite.region_rect.position.x = int(!Singleton.CurrentLevelData.level_data.vars.switch_state.has(palette)) * 32
	
	if !enabled:
		$StaticBody2D.set_collision_layer_bit(0, false)

	sprite.region_rect.position.y = palette * 32
	
	_connect()

func _connect():
	curve_tween.connect("curve_tween", self, "_on_curve_tween")
	Singleton.CurrentLevelData.level_data.vars.connect("switch_state_changed", self, "_on_switch_state_changed")
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
	switch_sound.play()
	Singleton.CurrentLevelData.level_data.vars.toggle_switch_state(palette)

func _on_curve_tween(value):
	sprite.position = value


