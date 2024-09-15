extends Block

onready var sprite = $Sprite
onready var outline = $Outline
onready var animation_player = $AnimationPlayer
onready var collider = $StaticBody2D/CollisionShape2D
onready var hit_area = $HitCollider
onready var hit_collider = $HitCollider/CollisionShape2D

var inverted : bool = false

func _set_properties():
	savable_properties = ["inverted", "palette"]
	editable_properties = ["inverted", "palette"]

func _set_property_values():
	set_property("inverted", inverted, false, null, ["base"])
	set_property("palette", palette, 0, null, ["base"])

func _ready():
	init()
	hit_bounce_enabled = false
	connect("property_changed", self, "_on_property_changed")
	if !enabled:
		$StaticBody2D.set_collision_layer_bit(0, false)
	if mode != 1:
		hit_area.connect("body_entered", self, "_on_hit_body_entered")
		hit_area.connect("area_entered", self, "_on_hit_area_entered")

	if palette != 0:
		#print(sprite.region_rect)
		sprite.region_rect.position.y = (float(palette) * 32) # changes sprite to correct position on that grid of palettes
		outline.animation = str(palette) + "_outline"

	switch_state(inverted)
	if Singleton.CurrentLevelData.level_data.vars.switch_state.has(palette):
		toggle_state()
	Singleton.CurrentLevelData.level_data.vars.connect("switch_state_changed", self, "_on_switch_state_changed")

func toggle_state():
	inverted = !inverted
	switch_state(inverted)

func switch_state(state):
	collider.set_deferred("disabled", state)
	hit_collider.set_deferred("disabled", state)
	animation_player.play(str(!state).to_lower())

func _on_switch_state_changed(channel):
	if palette == channel:
		toggle_state()

func _on_property_changed(key, value):
	if key == "inverted":
		collider.set_deferred("disabled", !value)
		hit_collider.set_deferred("disabled", !value)
		animation_player.play(str(!value).to_lower())
