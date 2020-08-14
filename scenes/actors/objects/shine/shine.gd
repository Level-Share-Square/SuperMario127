# TODO: 
# Shine Dance frames for fludd 
# Update ambient sound volume to consider both players (check cannon audio source script)
# Prvent pausing after collecting a star
extends GameObject

export var normal_frames : SpriteFrames
export var recolorable_frames : SpriteFrames

export var normal_particles : StreamTexture
export var recolorable_particles : StreamTexture

onready var animated_sprite : AnimatedSprite = $AnimatedSprite
onready var outline_sprite : AnimatedSprite = $AnimatedSpriteOutline
onready var particles : Particles2D = $AnimatedSprite/Particles2D
onready var ghost : Sprite = $Ghost
onready var area : Area2D = $Area2D
onready var unpause_timer : Timer = $UnpauseTimer
onready var collect_sound : AudioStreamPlayer = $CollectSound
onready var ambient_sound : AudioStreamPlayer = $AmbientSound
onready var animation_player : AnimationPlayer = $AnimationPlayer
onready var current_scene : Node = get_tree().current_scene
onready var transitions : Node = get_node("/root/scene_transitions")
onready var mode_switcher_button : Node = get_node("/root/mode_switcher/ModeSwitcherButton")

const UNPAUSE_TIMER_LENGTH = 3.35

const COURSE_CLEAR_MUSIC_ID := 28
const COURSE_CLEAR_MUSIC_VOLUME := -2.25
const SHINE_DANCE_END_DELAY := 1.25
const MUSIC_TRANSITION_TIME_PLAY_MODE := 0.5

var collected := false
var character : Character

var anim_damp := 160
const NORMAL_COLOR := Color(1, 1, 0)
const WHITE_COLOR := Color(1, 1, 1)

var last_color : Color

var title := "Unnamed Shine"
var description := "You can change this description in the Shine Sprite's properties menu."
var show_in_menu := true
var activated := true
var red_coins_activate := false
var shine_shards_activate := false
var color := Color(1, 1, 0)
var id := 0

func _set_properties() -> void:
	savable_properties = ["title", "description", "show_in_menu", "activated", "red_coins_activate", "shine_shards_activate", "color", "id"]
	editable_properties = ["title", "description", "show_in_menu", "activated", "red_coins_activate", "shine_shards_activate", "color", "id"]
	
func _set_property_values() -> void:
	set_property("title", title, true)
	set_property("description", description, true)
	set_property("show_in_menu", show_in_menu, true)
	set_property("activated", activated, true)
	set_property("red_coins_activate", red_coins_activate, true)
	set_property("shine_shards_activate", shine_shards_activate, true)
	set_property("color", color, true)
	set_property("id", id)

func _ready() -> void:
	if mode != 1: # not in edit mode
		if red_coins_activate or shine_shards_activate:
			activated = false
		# warning-ignore: return_value_discarded
		area.connect("body_entered", self, "collect")
		unpause_timer.wait_time = UNPAUSE_TIMER_LENGTH
	var _connect = connect("property_changed", self, "update_color")
	update_color("color", color)

#TODO: Make this work with the window preview
func update_color(key, value):
	if key == "color" and value != last_color:
		if color != NORMAL_COLOR:
			animated_sprite.self_modulate = color
			
			animated_sprite.frames = recolorable_frames
			particles.texture = recolorable_particles
		else:
			animated_sprite.self_modulate = WHITE_COLOR
			
			animated_sprite.frames = normal_frames
			particles.texture = normal_particles
		last_color = color

func _process(_delta):
	outline_sprite.frame = animated_sprite.frame
	outline_sprite.visible = animated_sprite.visible
	outline_sprite.offset = animated_sprite.offset
		
func _physics_process(_delta : float) -> void:
	if !animated_sprite.playing: #looks like if it is not set to playing, some manual animation is done instead
		#warning-ignore:integer_division
		animated_sprite.frame = wrapi(OS.get_ticks_msec() / (1000/8), 0, 16)
		
	if mode != 1:
		var camera : Camera2D = current_scene.get_node(current_scene.camera)
		if red_coins_activate and !activated:
			if CurrentLevelData.level_data.vars.red_coins_collected == CurrentLevelData.level_data.vars.max_red_coins:
				activate_shine()
		if shine_shards_activate and !activated:
			if CurrentLevelData.level_data.vars.shine_shards_collected == CurrentLevelData.level_data.vars.max_shine_shards:
				activate_shine()
		if !collected:
			if !activated:
				ambient_sound.playing = false
				ghost.visible = true
				animated_sprite.visible = false
			else:
				if !ambient_sound.playing:
					ambient_sound.playing = true
				ghost.visible = false
				animated_sprite.visible = true
		# need to change this to also take into account player 2
		ambient_sound.volume_db = -16 + -abs(camera.global_position.distance_to(global_position)/25)

	if collected:
		character.sprite.animation = "shineFall"
		character.sprite.rotation_degrees = 0
		
		ambient_sound.playing = false 
		music.playing = false
		
		if character.is_grounded():
			start_shine_dance() #shine dance setup also disables physics process, so it's only called once

func activate_shine() -> void:
	activated = true
	animation_player.play("appear")

	var camera = current_scene.get_node(current_scene.camera)
	camera.focus_on = self

	pause_mode = PAUSE_MODE_PROCESS
	get_tree().paused = true

	unpause_timer.start()
	# warning-ignore: return_value_discarded
	unpause_timer.connect("timeout", self, "unpause_game")

# unpauses the game after the activate shine cutscene is done
func unpause_game() -> void:
	var camera = current_scene.get_node(current_scene.camera)
	camera.focus_on = null
	get_tree().paused = false
	pause_mode = PAUSE_MODE_INHERIT

func collect(body : PhysicsBody2D) -> void:
	if activated and enabled and !collected and body.name.begins_with("Character") and body.controllable:
		character = body

		# hacky fix for the player being stuck in the ground during the shine dance if diving into a very low shine
		if character.state != null and character.state.name == "SlideState" and character.is_grounded():
			character.position.y -= 16

		character.anim_player.stop()
		character.set_state_by_name("FallState", get_physics_process_delta_time())
		character.velocity.x = 0
		character.sprite.rotation_degrees = 0
		character.controllable = false

		# fixes the player being in the ground if they dive into a shine in the air
		#character.set_state(null, get_physics_process_delta_time())
		character.call_deferred("set_dive_collision", false)

		character.set_collision_layer_bit(1, false) # disable collisions w/ most things
		character.set_inter_player_collision(false)

		mode_switcher_button.switching_disabled = true

		collect_sound.play() 
		collected = true
		visible = false

		if SavedLevels.selected_level != SavedLevels.NO_LEVEL:
			SavedLevels.levels[SavedLevels.selected_level].set_shine_collected(id)

func start_shine_dance() -> void:
	character.set_state_by_name("NoActionState", get_physics_process_delta_time())

	# make the character's victory shine sprite match this one
	character.collected_shine.self_modulate = animated_sprite.self_modulate
	character.collected_shine.frames = animated_sprite.frames
	character.collected_shine_particles.texture = particles.texture
	
	character.sprite.animation = "shineDance"
	character.anim_player.play("shine_dance")
	
	music.play_temporary_music(COURSE_CLEAR_MUSIC_ID, COURSE_CLEAR_MUSIC_VOLUME)
	
	# warning-ignore: return_value_discarded
	character.anim_player.connect("animation_finished", self, "character_shine_dance_finished")
	
	set_physics_process(false)

func character_shine_dance_finished(_animation : Animation) -> void:
	# delay a bit once the animation is done before starting the fadeout/transition back to the editor
	yield(get_tree().create_timer(SHINE_DANCE_END_DELAY), "timeout") 
	
	music.playing = true #we set it to false so it'd stop while falling with the shine, but now we need it to fade back in
	
	#bus is changed based on whether or not you are in the player, or editor, this makes sure music 
	#fades to the correct volume in both situations
	if mode_switcher_button.invisible: #if not running through the editor, play the transition
		music.bus = music.play_bus 
		music.stop_temporary_music(1, MUSIC_TRANSITION_TIME_PLAY_MODE)
		MenuVariables.quit_to_menu("levels_screen")
		#transitions.reload_scene(character.cutout_shine, character.cutout_circle, transitions.DEFAULT_TRANSITION_TIME, 0, true)
	else:
		music.bus = music.edit_bus
		music.stop_temporary_music()

		#mode switching is disabled on collecting the shine so the player can't cancel the animation (causes glitches)
		mode_switcher_button.switching_disabled = false 
		mode_switcher_button._pressed()
