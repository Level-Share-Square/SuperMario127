extends GameObject

const DEFAULT_HINT: String = "This Star Coin doesn't have a hint."
const DEFAULT_COLOR := Color.yellow

export var normal_frames : SpriteFrames
export var outline_frames : SpriteFrames
export var collected_frames : SpriteFrames
export var normal_particles : StreamTexture
export var recolorable_particles: StreamTexture
export var collected_particles : StreamTexture

onready var anim_sprite : AnimatedSprite = $AnimatedSprite
onready var recolorable : AnimatedSprite = $AnimatedSprite/Recolorable
onready var particles : Particles2D = $AnimatedSprite/Particles2D
onready var area : Area2D = $Area2D
onready var audio_player : AudioStreamPlayer = $AudioStreamPlayer
onready var animation_player : AnimationPlayer = $AnimationPlayer

var uuid: String = ""
var collected := false
var is_blue := false

var hint := DEFAULT_HINT
var color := DEFAULT_COLOR

var data: StarCoinData

#func _set_properties():
#	savable_properties = ["uuid"]
#	editable_properties = []

func _register_properties():
	register_property(4, "uuid", uuid, false)
	register_property(5, "hint", hint, true)
	register_property(6, "color", color, true)

func _ready() -> void:
	if not Singleton.ModeSwitcher.visible:
		# Get the value, returning false if the key doesn't exist
		is_blue = CurrentLevelData.save_data.is_star_coin_collected(uuid)
	
	update_color()
	anim_sprite.play("default")
	if not uuid:
		data = CurrentLevelData.level_metadata.collectible_data.add_star_coin()
		set_property("uuid", data.star_coin_uuid, true)
		set_property("hint", DEFAULT_HINT, true)
		set_property("color", DEFAULT_COLOR, true)
		
	connect("property_changed", self, "on_property_changed")

func on_property_changed(key, value):
	if key == "color":
		data.star_coin_color = color
		update_color()
	if key == "hint":
		data.star_coin_hint = hint

func _object_ready():
	._object_ready()
	var _connect = area.connect("body_entered", self, "collect")

func update_color():
	if !is_blue:
		if color != DEFAULT_COLOR:
			anim_sprite.frames = outline_frames
			recolorable.modulate = color
			recolorable.show()
			particles.texture = recolorable_particles
		else:
			anim_sprite.frames = normal_frames
			recolorable.hide()
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


func _object_removed(free: bool) -> void:
	._object_removed(free)

	CurrentLevelData.level_metadata.collectible_data.star_coin_data.erase(data)
	
func _object_restored() -> void:
	._object_restored()
	
	CurrentLevelData.level_metadata.collectible_data.star_coin_data.append(data)
