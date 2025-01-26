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
onready var ray_sprite : Sprite = $Sprite
onready var recolorable_ray_sprite : Sprite = $RecolorableRays
onready var particles : Particles2D = $AnimatedSprite/Particles2D
onready var ghost : Sprite = $Ghost
onready var area : Area2D = $Area2D
onready var unpause_timer : Timer = $UnpauseTimer
onready var collect_sound : AudioStreamPlayer = $CollectSound
onready var appear_sound = $AppearSound
onready var ambient_sound : AudioStreamPlayer = $AmbientSound
onready var animation_player : AnimationPlayer = $AnimationPlayer
onready var current_scene : Node = get_tree().current_scene
onready var shine_get : Node = current_scene.get_node_or_null("%ShineGet")
onready var transitions : Node = Singleton.SceneTransitions
onready var mode_switcher_button : Node = Singleton.ModeSwitcher.get_node("ModeSwitcherButton")

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
var send_score = false
var purple_starbits_activate := false

var title := "Unnamed Shine"
var description := ""
var show_in_menu := true
var activated := true
var red_coins_activate := false
var shine_shards_activate := false
var required_purples := 0
var color := Color(1, 1, 0)
var id := 0
var do_kick_out := true
var sort_position : int = 0
var activation_tag : String = "shine_tag"

var score_from_before = 0 # haha that rhymes

func _set_properties() -> void:
	savable_properties = ["title", "description", "show_in_menu", "activated", "red_coins_activate", "shine_shards_activate", "color", "id", "do_kick_out", "sort_position", "required_purples", "activation_tag"]
	editable_properties = ["title", "description", "show_in_menu", "activated", "red_coins_activate", "shine_shards_activate", "required_purples", "color", "do_kick_out", "activation_tag", "sort_position", "id"]
	
func _set_property_values() -> void:
	set_property("title", title, true)
	set_property("description", description, true)
	set_property("show_in_menu", show_in_menu, true)
	set_property("activated", activated, true)
	set_property("red_coins_activate", red_coins_activate, true)
	set_property("shine_shards_activate", shine_shards_activate, true)
	set_property("color", color, true)
	set_property("id", id, true, "ID")
#	set_property_menu("id", ["viewer"])
	set_property("do_kick_out", do_kick_out, true)
	set_property("sort_position", sort_position, true)
	set_property("required_purples", required_purples, true)
	set_property("activation_tag", activation_tag, true)

func _ready() -> void:
	send_score = true
	if mode != 1: # not in edit mode
		if required_purples > 0:
			purple_starbits_activate = true
			Singleton.CurrentLevelData.level_data.vars.required_purple_starbits[Singleton.CurrentLevelData.area].append(required_purples)
			Singleton.CurrentLevelData.level_data.vars.required_purple_starbits[Singleton.CurrentLevelData.area].sort()
		else:
			purple_starbits_activate = false
		if red_coins_activate or shine_shards_activate or purple_starbits_activate:
			activated = false
		var _connect = area.connect("body_entered", self, "collect")
		unpause_timer.wait_time = UNPAUSE_TIMER_LENGTH
		
		# if the shine is collected, make it blue 
		# (collected_shines is a Dictionary where the key is the shine id and the value is a bool)
		if Singleton.ModeSwitcher.get_node("ModeSwitcherButton").invisible:
			var collected_shines = Singleton.CurrentLevelData.level_info.collected_shines

			# Get the value, returning false if the key doesn't exist
			is_blue = collected_shines.get(str(id), false)
		if is_blue:
			recolorable_ray_sprite.visible = true
			recolorable_ray_sprite.modulate = Color.blue
	ray_sprite.visible = do_kick_out and !is_blue
	var _connect = connect("property_changed", self, "update_color")
	update_color("color", color)

func on_place():
	Singleton.CurrentLevelData.set_shine_ids()
	id = level_object.get_ref().properties[12]
	set_property("id", id)

func update_color(key, value):
	if key == "color" and value != last_color:
		if !is_blue:
			if color != NORMAL_COLOR:
				animated_sprite.self_modulate = color
				
				animated_sprite.frames = recolorable_frames
				particles.texture = recolorable_particles
				
				
				recolorable_ray_sprite.visible = true if do_kick_out else false
				ray_sprite.visible = false
				recolorable_ray_sprite.self_modulate = color
				recolorable_ray_sprite.self_modulate.s *= 3
			else:
				animated_sprite.self_modulate = WHITE_COLOR
				
				animated_sprite.frames = normal_frames
				particles.texture = normal_particles
				
				recolorable_ray_sprite.visible = false
				ray_sprite.visible = true if do_kick_out else false
				
				
		else:
			animated_sprite.self_modulate = WHITE_COLOR
			
			animated_sprite.frames = collected_frames
			particles.texture = collected_particles
			ray_sprite.visible = false
			recolorable_ray_sprite.visible = true if do_kick_out else false
			recolorable_ray_sprite.modulate = Color.blue
		last_color = value
	if key == "do_kick_out":
		if color != NORMAL_COLOR:
			recolorable_ray_sprite.visible = value
		else:
			ray_sprite.visible = value
func _process(_delta):
	outline_sprite.frame = animated_sprite.frame
	outline_sprite.visible = animated_sprite.visible
	outline_sprite.offset = animated_sprite.offset
	outline_sprite.flip_h = animated_sprite.flip_h

func _physics_process(_delta : float) -> void:
	animated_sprite.flip_h = !do_kick_out
	ray_sprite.rotation_degrees += 0.6
	recolorable_ray_sprite.transform = ray_sprite.transform
	recolorable_ray_sprite.modulate.a = ray_sprite.modulate.a
	if !animated_sprite.playing: #looks like if it is not set to playing, some manual animation is done instead
		#warning-ignore:integer_division
		animated_sprite.frame = wrapi(OS.get_ticks_msec() / (1000/8), 0, 16)
		
	if mode != 1:
		var camera : Camera2D = current_scene.get_node(current_scene.camera)
		var do_animation: bool = not (id in Singleton.CurrentLevelData.level_data.vars.activated_shine_ids)
		
		# band aid crash fix
		while Singleton.CurrentLevelData.level_data.vars.shine_shards_collected.size() <= Singleton.CurrentLevelData.area:
			Singleton.CurrentLevelData.level_data.vars.shine_shards_collected.append([0, []])
		while Singleton.CurrentLevelData.level_data.vars.purple_starbits_collected.size() <= Singleton.CurrentLevelData.area:
			Singleton.CurrentLevelData.level_data.vars.purple_starbits_collected.append([0, []])
		
		if red_coins_activate and !activated and Singleton.CurrentLevelData.level_data.vars.max_red_coins > 0:
			if Singleton.CurrentLevelData.level_data.vars.red_coins_collected[0] == Singleton.CurrentLevelData.level_data.vars.max_red_coins:
				activate_shine(do_animation)
		if shine_shards_activate and !activated and Singleton.CurrentLevelData.level_data.vars.max_shine_shards > 0:
			if Singleton.CurrentLevelData.level_data.vars.shine_shards_collected[Singleton.CurrentLevelData.area][0] == Singleton.CurrentLevelData.level_data.vars.max_shine_shards:
				activate_shine(do_animation)
		if purple_starbits_activate and !activated and Singleton.CurrentLevelData.level_data.vars.max_purple_starbits > 0:
			if Singleton.CurrentLevelData.level_data.vars.purple_starbits_collected[Singleton.CurrentLevelData.area][0] >= required_purples:
				activate_shine(do_animation)
		if !collected:
			if !activated:
				ambient_sound.playing = false
				ghost.visible = true
				animated_sprite.visible = false
				ray_sprite.modulate = Color(255, 255, 255, 0)
			else:
				if ambient_sound.playing == is_blue:
					ambient_sound.playing = !is_blue
				ghost.visible = false
				ray_sprite.self_modulate = WHITE_COLOR
				animated_sprite.visible = true
		# need to change this to also take into account player 2
		ambient_sound.volume_db = -16 + -abs(camera.global_position.distance_to(global_position)/25)

	if collected:
		if send_score == true:
			send_score = false
		character.shine_kill = true
		character.sprite.animation = "shineFall"
		character.sprite.rotation_degrees = 0
		
		ambient_sound.playing = false
		
		if character.is_grounded():
			start_shine_dance() #shine dance setup also disables physics process, so it's only called once

func activate_shine(do_animation: bool = true) -> void:
	activated = true
	
	if do_animation:
		
		while current_scene.character == null:
			yield(get_tree(), "idle_frame")
		var character = current_scene.get_node(current_scene.character)
		
		while !character.movable or !character.controllable:
			yield(get_tree(), "idle_frame")
		
		var camera = current_scene.get_node(current_scene.camera)
		
		pause_mode = PAUSE_MODE_PROCESS
		get_tree().paused = true
		Singleton.CurrentLevelData.can_pause = false
		
		var working_trans_time = 0.25
		
		if global_position.distance_to(character.global_position) <= 800:
			working_trans_time = 0.25
			
			var tween = get_tree().create_tween()
			tween.set_pause_mode(SceneTreeTween.TWEEN_PAUSE_PROCESS)
			tween.set_trans(Tween.TRANS_QUAD)
			
			tween.tween_property(camera, "global_position", global_position, .25)
			yield(get_tree().create_timer(working_trans_time), "timeout")
		else:
			working_trans_time = 0.5
			
			Singleton.SceneTransitions.do_transition_animation(Singleton.SceneTransitions.cutout_circle, 0.5)
			yield(get_tree().create_timer(working_trans_time), "timeout")
			camera.focus_on = self
			camera.auto_move = false
			camera.global_position = global_position
			camera.skip_to_player = true
		
		
		animation_player.play("appear")
		Singleton.CurrentLevelData.level_data.vars.activate_shine(id)
		
		unpause_timer.start()
		# warning-ignore: return_value_discarded
		unpause_timer.connect("timeout", self, "unpause_game")
	else:
		appear_sound.volume_db = -80
		animation_player.play("appear", -1, INF)

# unpauses the game after the activate shine cutscene is done
func unpause_game() -> void:
#	Singleton.SceneTransitions.do_transition_animation(Singleton.SceneTransitions.cutout_circle, 0.5)
	yield(get_tree().create_timer(0.5), "timeout")
	
	var character = current_scene.get_node(current_scene.character)
	var camera = current_scene.get_node(current_scene.camera)
	
	var working_trans_time = 0.25
	
	if global_position.distance_to(character.global_position) <= 800:
		working_trans_time = 0.25
		
		var tween = get_tree().create_tween()
		tween.set_pause_mode(SceneTreeTween.TWEEN_PAUSE_PROCESS)
		tween.set_trans(Tween.TRANS_QUAD)
		
		tween.tween_property(camera, "global_position", character.global_position, working_trans_time)
		yield(get_tree().create_timer(working_trans_time), "timeout")
	else:
		working_trans_time = 0.5
		
		Singleton.SceneTransitions.do_transition_animation(Singleton.SceneTransitions.cutout_circle, working_trans_time)
		yield(get_tree().create_timer(working_trans_time), "timeout")
		camera.focus_on = null
		camera.auto_move = true
		camera.global_position = character.global_position
		camera.skip_to_player = true
	
	yield(get_tree().create_timer(0.3), "timeout")
	
	get_tree().paused = false
	Singleton.CurrentLevelData.can_pause = true
	pause_mode = PAUSE_MODE_INHERIT

func collect(body : PhysicsBody2D) -> void:
	if activated and enabled and !collected and body.name.begins_with("Character") and body.controllable:
		character = body
		
		if do_kick_out:
			var timer_manager = get_node("/root").get_node("Player").get_timer_manager()
			if is_instance_valid(timer_manager):
				timer_manager.remove_timer("area_timer")
			else:
				printerr("Couldn't find timer manager node!")

		
		# hacky fix for the player being stuck in the ground during the shine dance if diving into a very low shine
		if character.state != null and character.state.name == "SlideState" and character.is_grounded():
			character.position.y -= 16

		Singleton.Music.stop_temporary_music()

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

		Singleton.ModeSwitcher.get_node("ModeSwitcherButton").switching_disabled = true
		Singleton.CurrentLevelData.can_pause = false

		# mute level music (gets un-muted after shine dance finishes)
		Singleton.Music.volume_multiplier = 0
		
		collect_sound.play() 
		character.set_zoom_tween(Vector2(0.8, 0.8), 0.5)
		collected = true
		visible = false

		if Singleton.ModeSwitcher.get_node("ModeSwitcherButton").invisible:
			score_from_before = Singleton.CurrentLevelData.time_score
			Singleton.CurrentLevelData.level_info.set_shine_collected(id, false)
			Singleton.CurrentLevelData.level_info.update_time_and_coin_score(id, true)
			Singleton.CurrentLevelData.stop_tracking_time_score()
			if !do_kick_out:
				var level_info = Singleton.CurrentLevelData.level_info
				var new_shine_id = level_info.selected_shine + 1
				if new_shine_id < level_info.shine_details.size():
					level_info.selected_shine = new_shine_id
				get_tree().get_current_scene().get_node("%PauseController").emit_signal("shine_collected")

func start_shine_dance() -> void:
	character.set_state_by_name("NoActionState", get_physics_process_delta_time())

	# make the character's victory shine sprite match this one
	character.collected_shine.self_modulate = animated_sprite.self_modulate
	character.collected_shine.frames = animated_sprite.frames
	character.collected_shine_particles.texture = particles.texture
	
	character.sprite.animation = "shineDance"
	character.anim_player.play("shine_dance")
	
	
	shine_get.appear(title)
	Singleton.Music.play_temporary_music(COURSE_CLEAR_MUSIC_ID, COURSE_CLEAR_MUSIC_VOLUME)
	
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
			var _connect = Singleton.SceneTransitions.connect("transition_finished", Singleton.SceneSwitcher, "quit_to_menu", ["levels_screen"], CONNECT_ONESHOT)
			Singleton.SceneTransitions.do_transition_animation(
				character.cutout_shine, 
				Singleton.SceneTransitions.DEFAULT_TRANSITION_TIME, 
				Singleton.SceneTransitions.TRANSITION_SCALE_UNCOVER, 
				Singleton.SceneTransitions.TRANSITION_SCALE_COVERED,
				0,
				0,
				true,
				true
			)
			
		else:
			# yes, another band aid
			yield(get_tree().create_timer(0.75), "timeout")
			mode_switcher_button.switching_disabled = false 
			mode_switcher_button._pressed()
			
			# pausing disabled for same reasons as mode switcher button
			Singleton.CurrentLevelData.can_pause = true
	else: 
		# start playing the dance stop animation
		shine_get.disappear()
		character.shine_kill = false
		character.anim_player.play("shine_dance_stop")
		character.anim_player.connect("animation_finished", self, "restore_control", [character], CONNECT_ONESHOT)

func restore_control(animation : String, character : Character) -> void:
	# bad code sorry
	yield(get_tree().create_timer(0.2), "timeout")

	# re-enable mode switching if in the editor test mode
	if !mode_switcher_button.invisible:
		mode_switcher_button.switching_disabled = false 

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
	
	# to prevent cheese on other shine time scores
	Singleton.CurrentLevelData.start_tracking_time_score()
	Singleton.CurrentLevelData.time_score = score_from_before
	
	Singleton.Music.stop_temporary_music()
