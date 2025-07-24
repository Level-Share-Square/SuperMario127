extends GameObject

onready var sprite = $Sprite
onready var area = $Area2D
onready var animation_player = $AnimationPlayer

var id: String
var color: Color
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
		Singleton.CurrentLevelData.level_data.vars.collect_local_key(id)
		print(Singleton.CurrentLevelData.level_data.vars.local_keys_collected)
		character = body
		collected = true
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
		
		visible = false
		
func play_get_anim():
	character.set_state_by_name("NoActionState", get_physics_process_delta_time())
	
	character.sprite.animation = "shineDance"
	character.anim_player.play("shine_dance")
	# warning-ignore: return_value_discarded
	character.anim_player.connect("animation_finished", self, "character_shine_dance_finished", [], CONNECT_ONESHOT)
	
	set_physics_process(false)
		
func character_shine_dance_finished(_animation: Animation):
	character.shine_kill = false
	character.anim_player.play("shine_dance_stop")
	character.anim_player.connect("animation_finished", self, "restore_control", [character], CONNECT_ONESHOT)

func restore_control(_animation : String, character : Character) -> void:
	# bad code sorry
	yield(get_tree().create_timer(0.2), "timeout")

	# re-enable mode switching if in the editor test mode

	# pausing disabled for same reasons as mode switcher button
	Singleton.CurrentLevelData.can_pause = true

	# stop the animation
	character.anim_player.stop()
	
	# hide the shine used for the shine dance animation
	character.hide_shine_dance_shine()
	
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

func _ready():
	if id in Singleton.CheckpointSaved.current_local_keys:
		queue_free()
	var _connect = area.connect("body_entered", self, "collect")
