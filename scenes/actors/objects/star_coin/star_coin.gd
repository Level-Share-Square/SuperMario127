extends GameObject

onready var anim_sprite : AnimatedSprite = $AnimatedSprite
onready var area : Area2D = $Area2D
onready var audio_player : AudioStreamPlayer = $AudioStreamPlayer 

var id : int = 0
var collected : bool = false

func _set_properties():
	savable_properties = ["id"]
	editable_properties = ["id"]

func _set_property_values():
	set_property("id", id)

func _ready() -> void:
	var _connect = area.connect("body_entered", self, "collect")

	anim_sprite.play("default")

func collect(body : PhysicsBody2D) -> void:
	if enabled and !collected and (body is Character):
		if mode_switcher.get_node("ModeSwitcherButton").invisible:
			SavedLevels.levels[SavedLevels.selected_level].set_star_coin_collected(id)

		collected = true

		anim_sprite.play("collected")
		var _connect = anim_sprite.connect("animation_finished", self, "queue_free")

		audio_player.play()
		
