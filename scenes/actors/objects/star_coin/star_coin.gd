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

var uuid: String = ""
var collected := false
var is_blue := false

#func _set_properties():
#	savable_properties = ["uuid"]
#	editable_properties = []

func _register_properties():
	register_property(4, "uuid", uuid, false)

func _ready() -> void:
	if not Singleton.ModeSwitcher.visible:
		# Get the value, returning false if the key doesn't exist
		is_blue = CurrentLevelData.save_data.is_star_coin_collected(uuid)

	update_color()
	anim_sprite.play("default")
	if not uuid:
		uuid = CurrentLevelData.level_metadata.collectible_data.add_star_coin()
		set_property("uuid", uuid, true)

func _object_ready():
	._object_ready()
	var _connect = area.connect("body_entered", self, "collect")

func update_color():
	if !is_blue:
		anim_sprite.frames = normal_frames
		particles.texture = normal_particles
	else:
		anim_sprite.frames = collected_frames
		particles.texture = collected_particles


func collect(body : PhysicsBody2D) -> void:
	if is_enabled_and_on_ground() and !collected and (body is Character):
		if not Singleton.ModeSwitcher.visible:
			CurrentLevelData.save_data.set_star_coin_collected(uuid, CurrentLevelData.selected_file > -2)

		collected = true

		animation_player.play("collect")
		var _connect = animation_player.connect("animation_finished", self, "queue_free")

		audio_player.play()

