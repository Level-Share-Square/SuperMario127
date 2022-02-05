extends Block

onready var sprite = $Sprite
onready var outline = $Outline
onready var animation_player = $AnimationPlayer
onready var collider = $StaticBody2D/CollisionShape2D
var inverted : bool = false

func _set_properties():
	savable_properties = ["inverted"]
	editable_properties = ["inverted"]

func _set_property_values():
	set_property("inverted", inverted, true)

func _ready():
	init()
	if !enabled:
		$StaticBody2D.set_collision_layer_bit(0, false)

	if palette != 0:
		print(sprite.region_rect)
		sprite.region_rect.position.y = (float(palette) * 32) # changes sprite to correct position on that grid of palettes
		outline.animation = str(palette) + "_outline"
		
	set_state(Singleton.CurrentLevelData.level_data.vars.switch_state[palette])
	Singleton.CurrentLevelData.level_data.vars.connect("switch_state_changed", self, "_on_switch_state_changed")

func set_state(state : bool):
	if inverted:
		collider.set_deferred("disabled", state)
		animation_player.play(str(!state).to_lower())
	else:
		collider.set_deferred("disabled", !state)
		animation_player.play(str(state).to_lower())

func _on_switch_state_changed(new_state, channel):
	if palette == channel:
		set_state(new_state)
