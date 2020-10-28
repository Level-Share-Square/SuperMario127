# TODO: 
# Shine Dance frames for fludd 
# Update ambient sound volume to consider both players (check cannon audio source script)
# Prvent pausing after collecting a star
extends GameObject

export var normal_frames : SpriteFrames
export var recolorable_frames : SpriteFrames
export var collected_frames : SpriteFrames

export var normal_particles : StreamTexture
export var recolorable_particles : StreamTexture
export var collected_particles : StreamTexture

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
const SHINE_DANCE_END_DELAY := 0.65
const MUSIC_TRANSITION_TIME_PLAY_MODE := 0.5

var collected := false
var character : Character

var anim_damp := 160
const NORMAL_COLOR := Color(1, 1, 0)
const WHITE_COLOR := Color(1, 1, 1)

var last_color : Color
var is_blue := false

var title := "Unnamed Shine"
var description := ""
var show_in_menu := true
var activated := true
var red_coins_activate := false
var shine_shards_activate := false
var color := Color(1, 1, 0)
var id := 0
var do_kick_out := true
var sort_position : int = 0

func _set_properties() -> void:
	savable_properties = ["title", "description", "show_in_menu", "activated", "red_coins_activate", "shine_shards_activate", "color", "id", "do_kick_out", "sort_position"]
	editable_properties = ["title", "description", "show_in_menu", "activated", "red_coins_activate", "shine_shards_activate", "color", "do_kick_out", "sort_position"]
	
func _set_property_values() -> void:
	set_property("title", title, true)
	set_property("description", description, true)
	set_property("show_in_menu", show_in_menu, true)
	set_property("activated", activated, true)
	set_property("red_coins_activate", red_coins_activate, true)
	set_property("shine_shards_activate", shine_shards_activate, true)
	set_property("color", color, true)
	set_property("id", id, true)
	set_property("do_kick_out", do_kick_out, true)
	set_property("sort_position", sort_position, true)

func _ready() -> void:
	if mode != 1: # not in edit mode
		if red_coins_activate or shine_shards_activate:
			activated = false
		var _connect = area.connect("body_entered", self, "collect")
		unpause_timer.wait_time = UNPAUSE_TIMER_LENGTH
		
		# if the shine is collected, make it blue 
		# (collected_shines is a Dictionary where the key is the shine id and the value is a bool)
		if SavedLevels.selected_level != SavedLevels.NO_LEVEL && \
		mode_switcher.get_node("ModeSwitcherButton").invisible:
			var collected_shines = SavedLevels.get_current_levels()[SavedLevels.selected_level].collected_shines

			# Get the value, returning false if the key doesn't exist
			is_blue = collected_shines.get(str(id), false)

	if !is_preview and mode == 1:
		id = CurrentLevelData.next_shine_id
		CurrentLevelData.next_shine_id += 1
		set_property("id", id)
	
	var _connect = connect("property_changed", self, "update_color")
	update_color("color", color)

func update_color(key, value):
	if key == "color" and value != last_color:
		if !is_blue:
			if color != NORMAL_COLOR:
				animated_sprite.self_modulate = color
				
				animated_sprite.frames = recolorable_frames
				particles.texture = recolorable_particles
			else:
				animated_sprite.self_modulate = WHITE_COLOR
				
				animated_sprite.frames = normal_frames
				particles.texture = normal_particles
		else:
			animated_sprite.self_modulate = WHITE_COLOR
			
			animated_sprite.frames = collected_frames
			particles.texture = collected_particles
		last_color = value

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
		if red_coins_activate and !activated and CurrentLevelData.level_data.vars.max_red_coins > 0:
			if CurrentLevelData.level_data.vars.red_coins_collected == CurrentLevelData.level_data.vars.max_red_coins:
				activate_shine()
		if shine_shards_activate and !activated and CurrentLevelData.level_data.vars.max_shine_shards > 0:
			if CurrentLevelData.level_data.vars.shine_shards_collected == CurrentLevelData.level_data.vars.max_shine_shards:
				activate_shine()
		if !collected:
			if !activated:
				ambient_sound.playing = false
				ghost.visible = true
				animated_sprite.visible = false
			else:
				if ambient_sound.playing == is_blue:
					ambient_sound.playing = !is_blue
				ghost.visible = false
				animated_sprite.visible = true
		# need to change this to also take into account player 2
		ambient_sound.volume_db = -16 + -abs(camera.global_position.distance_to(global_position)/25)

	if collected:
		character.sprite.animation = "shineFall"
		character.sprite.rotation_degrees = 0
		
		ambient_sound.playing = false 
		
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
		CurrentLevelData.can_pause = false

		# mute level music (gets un-muted after shine dance finishes)
		music.volume_multiplier = 0

		collect_sound.play() 
		collected = true
		visible = false

		if mode_switcher.get_node("ModeSwitcherButton").invisible and SavedLevels.selected_level != SavedLevels.NO_LEVEL:
			SavedLevels.get_current_levels()[SavedLevels.selected_level].set_shine_collected(id, false)
			SavedLevels.get_current_levels()[SavedLevels.selected_level].update_time_and_coin_score(id, true)
			if do_kick_out: # keep tracking the time score if you continue the level, to prevent cheese on other shine time scores
				CurrentLevelData.stop_tracking_time_score() # time score is saved, and we don't want it continuing to update into the menu wasting resources

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
	character.anim_player.connect("animation_finished", self, "character_shine_dance_finished", [], CONNECT_ONESHOT)
	
	set_physics_process(false)

func character_shine_dance_finished(_animation : Animation) -> void:
	# delay a bit once the animation is done before starting the fadeout/transition back to the editor
	yield(get_tree().create_timer(SHINE_DANCE_END_DELAY), "timeout") 
	
	#bus is changed based on whether or not you are in the player, or editor, this makes sure music 
	#fades to the correct volume in both situations
	if do_kick_out:
		if mode_switcher_button.invisible: #if not running through the editor, play the transition
			var _connect = scene_transitions.connect("transition_finished", MenuVariables, "quit_to_menu", ["levels_screen"], CONNECT_ONESHOT)
			scene_transitions.do_transition_animation(
				character.cutout_shine, 
				scene_transitions.DEFAULT_TRANSITION_TIME, 
				scene_transitions.TRANSITION_SCALE_UNCOVER, 
				scene_transitions.TRANSITION_SCALE_COVERED,
				0,
				0,
				true,
				false
			)
		else:
			# yes, another band aid
			yield(get_tree().create_timer(0.75), "timeout")
			mode_switcher_button.switching_disabled = false 
			mode_switcher_button._pressed()
			
			# pausing disabled for same reasons as mode switcher button
			CurrentLevelData.can_pause = true
	else: 
		# start playing the dance stop animation
		character.anim_player.play("shine_dance_stop")
		character.anim_player.connect("animation_finished", self, "restore_control", [character], CONNECT_ONESHOT)

func restore_control(animation : String, character : Character) -> void:
	# bad code sorry
	yield(get_tree().create_timer(0.2), "timeout")

	# re-enable mode switching if in the editor test mode
	if !mode_switcher_button.invisible:
		mode_switcher_button.switching_disabled = false 

	# pausing disabled for same reasons as mode switcher button
	CurrentLevelData.can_pause = true

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
	
	music.stop_temporary_music()
