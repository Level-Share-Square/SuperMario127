extends GameObject

export var normal_frames : SpriteFrames
export var collected_frames : SpriteFrames
export var normal_particles : StreamTexture
export var collected_particles : StreamTexture

onready var anim_sprite : AnimatedSprite = $AnimatedSprite
onready var particles : Particles2D = $AnimatedSprite/Particles2D
onready var area : Area2D = $Area2D
onready var audio_player : AudioStreamPlayer = $AudioStreamPlayer
onready var animation_player : AnimationPlayer = $AnimationPlayer

var id : int = 0
var collected := false
var is_blue := false

func _set_properties():
	savable_properties = ["id"]
	editable_properties = []

func _set_property_values():
	set_property("id", id)

func _ready() -> void:
	var _connect = area.connect("body_entered", self, "collect")

	if Singleton.ModeSwitcher.get_node("ModeSwitcherButton").invisible:
		var collected_star_coins = Singleton.CurrentLevelData.level_info.collected_star_coins
		# Get the value, returning false if the key doesn't exist
		is_blue = collected_star_coins.get(str(id), false)

	update_color()
	anim_sprite.play("default")

func on_place():
	Singleton.CurrentLevelData.set_star_coin_ids()
	id = level_object.get_ref().properties[5]
	set_property("id", id)

func update_color():
	if !is_blue:
		anim_sprite.frames = normal_frames
		particles.texture = normal_particles
	else:
		anim_sprite.frames = collected_frames
		particles.texture = collected_particles

func collect(body : PhysicsBody2D) -> void:
	if enabled and !collected and (body is Character):
		if Singleton.ModeSwitcher.get_node("ModeSwitcherButton").invisible:
			Singleton.CurrentLevelData.level_info.set_star_coin_collected(id)

		collected = true

		animation_player.play("collect")
		var _connect = animation_player.connect("animation_finished", self, "queue_free")

		audio_player.play()

