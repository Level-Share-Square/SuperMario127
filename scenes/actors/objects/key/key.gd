extends GameObject

const DEFAULT_COLOR: Color = Color.yellow
const DEFAULT_TEXTURE: StreamTexture = preload("res://scenes/actors/objects/key/key.png")
const RECOLORABLE_TEXTURE: StreamTexture = preload("res://scenes/actors/objects/key/key_recolorable.png")

onready var sprite = $Sprite
onready var vector_rays = $Sprite/VectorRays
onready var area = $Area2D
onready var collect_sound = $CollectSound
onready var collect_jingle = $CollectJingle

onready var current_scene : Node = get_tree().current_scene
onready var key_get : Node = current_scene.get_node_or_null("%KeyGet")

var id: String
var color: Color = Color.yellow

var collected = false
var character

func _set_properties():
	savable_properties = ["id", "color"]
	editable_properties = ["id", "color"]

func _set_property_values():
	set_property("id", id)
	set_property("color", color)
	
func _physics_process(delta):
	if collected:
		if character.is_grounded(): #character isnt defined until later
			play_get_anim()

func collect(body):
	if enabled and body.name.begins_with("Character") and !body.dead:
		CurrentLevelData.vars.collect_local_key(id)
		#print(CurrentLevelData.vars.local_keys_collected)
		character = body
		collected = true
		collect_sound.play()
		body.anim_player.stop()
		body.set_state_by_name("FallState", get_physics_process_delta_time())
		body.velocity.x = 0
		body.sprite.rotation_degrees = 0
		body.controllable = false
		body.sprite.animation = "shineFall"
		body.sprite.rotation_degrees = 0

		body.call_deferred("set_dive_collision", false)

		body.set_collision_layer_bit(1, false)
		body.set_inter_player_collision(false)
		
		Singleton.Music.volume_multiplier = 0.33
		visible = false
		
func play_get_anim():
	character.set_state_by_name("NoActionState", get_physics_process_delta_time())
	
	key_get.appear(id)
	
	collect_jingle.play()
	
	# make the character's held key match this one
	character.collected_key.self_modulate = sprite.self_modulate
	character.collected_key.texture = sprite.texture
	character.collected_key_rays.color = color
	
	character.anim_player.play("key_dance")
	# warning-ignore: return_value_discarded
	character.anim_player.connect("animation_finished", self, "restore_control", [character], CONNECT_ONESHOT)
	
	set_physics_process(false)

func restore_control(_animation : String, character : Character) -> void:
	# bad code sorry
	yield(get_tree().create_timer(0.2), "timeout")
	
	key_get.disappear()
	Singleton.Music.volume_multiplier = 1
	character.shine_kill = false

	# pausing disabled for same reasons as mode switcher button
	CurrentLevelData.can_pause = true

	# stop the animation
	character.anim_player.stop()
	
	# player animations won't play past frame 0 after the shine dance without this
	character.sprite.playing = true
		
	# undo collision changes 
	character.set_collision_layer_bit(1, true)
	character.set_inter_player_collision(true) 
	character.call_deferred("set_dive_collision", true)

	# return the character to a state they can actually move around in
	character.set_state(null, get_physics_process_delta_time())
	character.controllable = true
	character.shine_cutscene = false
	queue_free()

func update_property(key, value):
	if key == "color":
		vector_rays.color = color
		if color == DEFAULT_COLOR:
			sprite.texture = DEFAULT_TEXTURE
			sprite.self_modulate = Color.white
		else:
			sprite.texture = RECOLORABLE_TEXTURE
			sprite.self_modulate = color

func _object_ready():
	if id in CurrentLevelData.checkpoint_data.current_local_keys:
		queue_free()
	var _connect = area.connect("body_entered", self, "collect")
	
func _editor_ready():
	var _connect = connect("property_changed", self, "update_property")
	update_property("color", color)
