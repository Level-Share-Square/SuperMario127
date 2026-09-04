# TODO: 
# Shine Dance frames for fludd 
# Update ambient sound volume to consider both players (check cannon audio source script)
# Prvent pausing after collecting a star
extends GameObject

export var normal_frames: SpriteFrames
export var recolorable_frames: SpriteFrames
export var collected_frames: SpriteFrames

export var pocket_frames: SpriteFrames
export var pocket_recolorable_frames: SpriteFrames
export var pocket_collected_frames: SpriteFrames

export var normal_particles: StreamTexture
export var recolorable_particles: StreamTexture
export var collected_particles: StreamTexture

export var normal_spawn_particles: Texture
export var recolorable_spawn_particles: Texture
export var collected_spawn_particles: Texture

onready var animated_sprite: AnimatedSprite = $AnimatedSprite
onready var recolorable_sprite: AnimatedSprite = $AnimatedSprite/AnimatedSpriteRecolorable
onready var vector_rays: ColorRect = $RaysContainer/VectorRays
onready var vector_rays_small: ColorRect = $RaysContainer/VectorRaysSmall
onready var glow = $RaysContainer/Glow
onready var particles: Particles2D = $AnimatedSprite/Particles2D
onready var spawn_particles: Particles2D = $SpawnParticles
onready var ghost: Sprite = $Ghost
onready var area: Area2D = $Area2D
onready var unpause_timer: Timer = $UnpauseTimer
onready var allow_cutscene_timer: Timer = $AllowCutsceneTimer
onready var collect_sound: AudioStreamPlayer2D = $CollectSound
onready var appear_sound = $AppearSound
onready var ambient_sound: AudioStreamPlayer2D = $AmbientSound
onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var current_scene: Node = get_tree().current_scene
onready var shine_get: Node = current_scene.get_node_or_null("%ShineGet")
onready var transitions = SceneTransitions

const UNPAUSE_TIMER_LENGTH = 3.35

const COURSE_CLEAR_MUSIC_ID:= 28
const POCKET_CLEAR_MUSIC_ID:= 71
const COURSE_CLEAR_MUSIC_VOLUME:= -2.25
const SHINE_DANCE_END_DELAY:= 0.65
const MUSIC_TRANSITION_TIME_PLAY_MODE:= 0.5

enum ActivateAnimations {NORMAL, SKIP, SHORT}

var collected:= false
var character

var anim_damp:= 160
const NORMAL_COLOR:= Color(1, 1, 0)
const NORMAL_RAY_COLOR:= Color8(227, 205, 10)
const WHITE_COLOR:= Color(1, 1, 1)

var last_color: Color
var is_blue:= false
var send_score = false
var purple_starbits_activate:= false

var title:= "Unnamed Shine"
var do_kick_out: bool = true
var activated: bool = true
var red_coins_activate: bool = false
var shine_shards_activate: bool = false
var required_purples: int = 0
var color := Color.yellow
var mission_uuid: String = ""
var activation_tag: String = ""
var added_to_data: bool = false

var score_from_before = 0 # haha that rhymes
var mission_from_before = "" # haha that's the same as the above variable

signal shine_collected
signal shine_dance_end


#func _set_properties() -> void:
#	savable_properties = ["activated", "red_coins_activate", "shine_shards_activate", "color", "mission_uuid", "required_purples", "activation_tag"]
#	editable_properties = ["mission_uuid", "activated", "red_coins_activate", "shine_shards_activate", "required_purples", "color", "activation_tag"]


func _register_properties() -> void:
	register_property(4, "activated", activated, true)
	register_property(5, "red_coins_activate", red_coins_activate, true)
	register_property(6, "shine_shards_activate", shine_shards_activate, true)
	register_property(7, "mission_uuid", mission_uuid, false)
	register_property(8, "required_purples", required_purples, true)
	register_property(9, "activation_tag", activation_tag, true)
	register_property(10, "added_to_data", added_to_data, false)
	property_tabs.append("mission")
	
func _register_property_info() -> void:
	set_property_info("activated", PropertyInfo.new("Determines if the Shine Sprite is activated by default.\nWhen deactivated, this Shine Sprite appears as a Shine Marker\nuntil any activation condition is met.", 1, -INF, INF, ["", ""], ["", ""], false, ""))
	set_property_info("red_coins_activate", PropertyInfo.new("This Shine Sprite activates once every Red Coin in the level is collected.\nRed Coins are tracked across all areas of a level.", 1, -INF, INF, ["", ""], ["", ""], false, ""))
	set_property_info("shine_shards_activate", PropertyInfo.new("This Shine Sprite activates once every Shine Shard in this area is collected.\nShine Shards are local to the current area.", 1, -INF, INF, ["", ""], ["", ""], false, ""))
	set_property_info("mission_uuid", PropertyInfo.new("Determines what Mission this Shine Sprite corralates to.\nMissions determine how many Shine Sprite objectives there are in the level,\nand dictate things such as their Names, Descriptions, and Shine Color.", 1, -INF, INF, ["", ""], ["", ""], false, "Mission"))
	set_property_info("required_purples", PropertyInfo.new("This Shine Sprite activates once the\nstated number of Purple Starbits in this area are collected.\nPurple Starbits are local to the current area.", 1, 0, INF, ["", ""], ["", ""], false, ""))
	set_property_info("activation_tag", PropertyInfo.new("Used by the 'Shine Tag' property of Shine Activators to activate this Shine Sprite.", 1, -INF, INF, ["", ""], ["", ""], false, ""))
	
func get_mission_args() -> Dictionary:
	var args: Dictionary
	for mission_data in CurrentLevelData.level_metadata.collectible_data.mission_data:
		args.get_or_add(mission_data.mission_uuid, mission_data.shine_name)
	return args

func _ready() -> void:
	send_score = true
	if mission_uuid:
		mission_from_before = mission_uuid
		update_shine_properties("mission_uuid", mission_uuid)
	if mode != 1: # not in edit mode
		if required_purples > 0:
			purple_starbits_activate = true
			CurrentLevelData.vars.required_purple_starbits[CurrentLevelData.area_id].append(required_purples)
			CurrentLevelData.vars.required_purple_starbits[CurrentLevelData.area_id].sort()
		else:
			purple_starbits_activate = false
		
		if red_coins_activate or shine_shards_activate or purple_starbits_activate:
			activated = false
		unpause_timer.wait_time = UNPAUSE_TIMER_LENGTH
		
		var _connect = area.connect("body_entered", self, "collect")
		
		if activated:
			animation_player.play("active")
			ambient_sound.playing = !is_blue
		else:
			animation_player.play("inactive")
		
		# if the shine is collected, make it blue 
		# (collected_shines is a Dictionary where the key is the shine id and the value is a bool)
		if not Singleton.ModeSwitcher.visible:

			# Get the value, returning false if the key doesn't exist
			is_blue = CurrentLevelData.save_data.is_mission_complete(mission_uuid)
		if is_blue:
			vector_rays.color = Color.blue
		else:
			vector_rays.color = color
			vector_rays.color.s *= 3
			vector_rays_small.color = vector_rays.color
		vector_rays_small.color = vector_rays.color
	else:
		animation_player.play("RESET")
		CurrentLevelData.level_metadata.collectible_data.connect("data_changed", self, "on_mission_changed")
	
	vector_rays.visible = do_kick_out and !is_blue
	glow.visible = !is_blue
	
	var _connect = connect("property_changed", self, "update_shine_properties")
	if activation_tag != "":
		add_to_group("tag_shine_%s" % activation_tag.to_lower())
		

func on_mission_changed(mission):
	if mission.mission_uuid == mission_uuid:
		update_shine_properties("mission_uuid", mission.mission_uuid)

func update_shine_properties(key: String, value) -> void:
	if key == "mission_uuid":
		var collectible_data = CurrentLevelData.level_metadata.collectible_data
		var mission_data: MissionData = collectible_data.get_mission_by_uuid(value)
		var used_mission_data: Dictionary = collectible_data.used_mission_data
		
		if added_to_data and mission_uuid != mission_from_before and mission_from_before != "":
			if used_mission_data.has(mission_from_before):
				used_mission_data[mission_from_before] -= 1
				
				if used_mission_data[mission_from_before] <= 0:
					used_mission_data.erase(mission_from_before)

		if not added_to_data or mission_from_before != mission_uuid:
			if used_mission_data.has(mission_uuid): 
				used_mission_data[mission_uuid] += 1
			else: 
				used_mission_data[mission_uuid] = 1 
				
			set_property("added_to_data", true, true)
			added_to_data = true
		
		mission_from_before = value
		
		is_blue = mission_uuid in CurrentLevelData.save_data.get_completed_missions()
		do_kick_out = mission_data.shine_force_leave
		update_color("color", mission_data.shine_color)
		title = mission_data.shine_name

func _object_removed(free: bool) -> void:
	._object_removed(free)
	
	var dict = CurrentLevelData.level_metadata.collectible_data.used_mission_data
	if dict.has(mission_uuid):
		dict[mission_uuid] -= 1
		if dict[mission_uuid] <= 0:
			dict.erase(mission_uuid)
	
func _object_restored() -> void:
	._object_restored()
	
	var dict = CurrentLevelData.level_metadata.collectible_data.used_mission_data
	if dict.has(mission_uuid):
		dict[mission_uuid] += 1
	else:
		dict[mission_uuid] = 1


func update_color(key, value):
	if key == "color":
		color = value
		if !is_blue:
			animated_sprite.frames = normal_frames if do_kick_out else pocket_frames
			animated_sprite.self_modulate = WHITE_COLOR
			
			if color != NORMAL_COLOR:
				recolorable_sprite.self_modulate = color
				recolorable_sprite.frames = recolorable_frames if do_kick_out else pocket_recolorable_frames
				recolorable_sprite.show()
				
				particles.texture = recolorable_particles
				
				spawn_particles.self_modulate = color
				spawn_particles.texture = recolorable_spawn_particles
				
				vector_rays.visible = true if do_kick_out else false
				vector_rays.color = color
				vector_rays.color.s *= 3
			else:
				recolorable_sprite.hide()
				
				particles.texture = normal_particles
				
				spawn_particles.self_modulate = WHITE_COLOR
				spawn_particles.texture = normal_spawn_particles
				
				vector_rays.visible = true if do_kick_out else false
		else:
			animated_sprite.self_modulate = WHITE_COLOR
			animated_sprite.frames = collected_frames if do_kick_out else pocket_collected_frames
			recolorable_sprite.hide()
			
			particles.texture = collected_particles
			
			if color != NORMAL_COLOR:
				spawn_particles.self_modulate = color
				spawn_particles.texture = recolorable_spawn_particles
			else:
				spawn_particles.self_modulate = WHITE_COLOR
				spawn_particles.texture = collected_spawn_particles
			
			vector_rays.visible = true if do_kick_out else false
			vector_rays.color = Color.blue
	
	if key == "do_kick_out":
		if color != NORMAL_COLOR:
			vector_rays.color = color
		else:
			vector_rays.color = NORMAL_RAY_COLOR
	
	glow.visible = !is_blue
	vector_rays_small.color = vector_rays.color


func _physics_process(_delta: float) -> void:
	animated_sprite.flip_h = !do_kick_out
	if !animated_sprite.playing: #looks like if it is not set to playing, some manual animation is done instead
		#warning-ignore:integer_division
		animated_sprite.frame = wrapi(OS.get_ticks_msec() / (1000/8), 0, 16)
		
	if mode != 1:
		var do_animation: bool = not (mission_uuid in CurrentLevelData.vars.activated_shine_ids)
#		var do_animation: bool = true
		
		# band aid crash fix
		while CurrentLevelData.vars.shine_shards_collected.size() <= CurrentLevelData.area_id:
			CurrentLevelData.vars.shine_shards_collected.append([0, []])
		while CurrentLevelData.vars.purple_starbits_collected.size() <= CurrentLevelData.area_id:
			CurrentLevelData.vars.purple_starbits_collected.append([0, []])
		
		if allow_cutscene_timer.is_stopped():
			if red_coins_activate and !activated and CurrentLevelData.level_metadata.collectible_data.red_coin_count > 0:
				if CurrentLevelData.vars.red_coins_collected[0] == CurrentLevelData.level_metadata.collectible_data.red_coin_count:
					activate_shine(ActivateAnimations.NORMAL if do_animation else ActivateAnimations.SKIP, false, true)
			if shine_shards_activate and !activated and CurrentLevelData.vars.max_shine_shards > 0:
				if CurrentLevelData.vars.shine_shards_collected[CurrentLevelData.area_id][0] == CurrentLevelData.area_headers[CurrentLevelData.area_id].shine_shard_count:
					activate_shine(ActivateAnimations.NORMAL if do_animation else ActivateAnimations.SKIP, false, true)
			if purple_starbits_activate and !activated and CurrentLevelData.vars.max_purple_starbits > 0:
				if CurrentLevelData.vars.purple_starbits_collected[CurrentLevelData.area_id][0] >= required_purples:
					activate_shine(ActivateAnimations.NORMAL if do_animation else ActivateAnimations.SKIP, false, true)
	
	if collected:
		if send_score == true:
			send_score = false
		character.shine_kill = true
		character.sprite.animation = "shineFall"
		character.sprite.rotation_degrees = 0
		
		ambient_sound.playing = false
		
		if character.is_grounded():
			start_shine_dance() #shine dance setup also disables physics process, so it's only called once


func activate_shine(animation: int, temporary: bool = false, manual_start_cutscene: bool = false) -> void:
	pause_mode = PAUSE_MODE_INHERIT
	if activated:
		return
		
	activated = true
	
	yield(get_tree(), "idle_frame")
	
	character = current_scene.get_node(current_scene.character)
	while !is_instance_valid(character):
		yield(get_tree(), "idle_frame")
		character = current_scene.get_node(current_scene.character)
		
	var camera = current_scene.get_node(current_scene.camera)
	while !is_instance_valid(camera):
		yield(get_tree(), "idle_frame")
		camera = current_scene.get_node(current_scene.camera)
	
	if animation == ActivateAnimations.NORMAL:
		var cutscene: CameraCutscene = CameraCutscene.new()
		cutscene.cutscene_type = cutscene.Type.AUTO
		cutscene.tween_ease = Tween.EASE_IN_OUT
		cutscene.transition_type = Tween.TRANS_LINEAR
		cutscene.time = 0.25
		cutscene.animation = "appear"
		cutscene.set_up(self, global_position)
		camera.queue_cutscene(cutscene)
	elif animation == ActivateAnimations.SHORT:
		var cutscene: CameraCutscene = CameraCutscene.new()
		cutscene.cutscene_type = cutscene.Type.AUTO
		cutscene.tween_ease = Tween.EASE_IN_OUT
		cutscene.transition_type = Tween.TRANS_LINEAR
		cutscene.time = 0.25
		cutscene.animation = "appear_short"
		cutscene.set_up(self, global_position)
		camera.queue_cutscene(cutscene)
	else:
		yield(get_tree(), "idle_frame")
		appear_sound.volume_db = -80
		animation_player.play("active", -1, INF)
	
	
	if !temporary:
		CurrentLevelData.vars.activate_shine(mission_uuid)
	
	if manual_start_cutscene:
		camera.start_queue()


func deactivate_shine(do_animation: bool) -> void:
	if !activated:
		return
	
	animation_player.play("disappear")
	
	activated = false
	CurrentLevelData.vars.deactivate_shine(mission_uuid)


# Updates the ambient noise appropriately depending on if the shine is active and not collected prior.
func update_ambient_noise() -> void:
	ambient_sound.playing = activated and !is_blue


func collect(body: PhysicsBody2D) -> void:
	if activated and is_enabled_and_on_ground() and !collected and body.name.begins_with("Character") and body.controllable:
		
		var timer_manager = get_node("/root").get_node("Player").get_timer_manager()
		timer_manager.pause_resume_timer("area_timer", true)
		
		emit_signal("shine_collected")
		
		character = body
		
		if do_kick_out:
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
		character.shine_cutscene = true

		# fixes the player being in the ground if they dive into a shine in the air
		#character.set_state(null, get_physics_process_delta_time())
		character.call_deferred("set_dive_collision", false)

		character.set_collision_layer_bit(1, false) # disable collisions w/ most things
		character.set_inter_player_collision(false)

		Singleton.ModeSwitcher.is_switching = true
		CurrentLevelData.can_pause = false

		# mute level music (gets un-muted after shine dance finishes)
		Singleton.Music.volume_multiplier = 0
		
		collect_sound.play() 
		character.set_zoom_tween(Vector2(0.8, 0.8), 0.5)
		collected = true
		visible = false

		if not Singleton.ModeSwitcher.visible:
			var is_new_record: bool = CurrentLevelData.save_data.is_new_record(mission_uuid)

			score_from_before = CurrentLevelData.time_score
			CurrentLevelData.save_data.set_mission_complete(mission_uuid, false)
			CurrentLevelData.save_data.update_time_and_coin_score(mission_uuid, CurrentLevelData.selected_file > -2)
			CurrentLevelData.pause_time_score()
			if !do_kick_out:
				get_tree().get_current_scene().get_node("%PauseController").emit_signal("shine_collected")
			elif CurrentLevelData.is_playing_campaign():
				CurrentLevelData.shine_kickout_data = {
					"title": title,
					"time_score": score_from_before,
					"new_record": is_new_record
				}

func start_shine_dance() -> void:
	character.set_state_by_name("NoActionState", get_physics_process_delta_time())

	# make the character's victory shine sprite match this one
	character.collected_shine.frames = animated_sprite.frames
	
	character.collected_shine_recolorable.frames = recolorable_sprite.frames
	character.collected_shine_recolorable.self_modulate = recolorable_sprite.self_modulate
	character.collected_shine_recolorable.visible = recolorable_sprite.visible
	
	character.collected_shine_particles.texture = particles.texture
	character.collected_shine_particles.self_modulate = particles.self_modulate
	
	character.sprite.animation = "shineDance"
	character.anim_player.play("shine_dance")
	
	
	shine_get.appear(title)
	Singleton.Music.play_temporary_music(COURSE_CLEAR_MUSIC_ID if do_kick_out else POCKET_CLEAR_MUSIC_ID, COURSE_CLEAR_MUSIC_VOLUME)
	
	# warning-ignore: return_value_discarded
	character.anim_player.connect("animation_finished", self, "character_shine_dance_finished", [], CONNECT_ONESHOT)
	
	set_physics_process(false)

func character_shine_dance_finished(_animation: Animation) -> void:
	# delay a bit once the animation is done before starting the fadeout/transition back to the editor
	yield(get_tree().create_timer(SHINE_DANCE_END_DELAY), "timeout") 
	#bus is changed based on whether or not you are in the player, or editor, this makes sure music 
	#fades to the correct volume in both situations
	if do_kick_out:
		CurrentLevelData.unpause_time_score()
		if not Singleton.ModeSwitcher.visible: #if not running through the editor, play the transition
			var _connect = SceneTransitions.connect("transition_finished", Singleton.SceneSwitcher, "quit_level", [false], CONNECT_ONESHOT)
			SceneTransitions.do_transition_animation(
				character.cutout_shine, 
				SceneTransitions.DEFAULT_TRANSITION_TIME, 
				SceneTransitions.TRANSITION_SCALE_UNCOVER, 
				SceneTransitions.TRANSITION_SCALE_COVERED,
				0,
				0,
				true,
				true
			)
			
		else:
			# yes, another band aid
			yield(get_tree().create_timer(0.75), "timeout")
			Singleton.ModeSwitcher.is_switching = false 
			Singleton.ModeSwitcher.pressed(true, true)
			
			# pausing disabled for same reasons as mode switcher button
			CurrentLevelData.can_pause = true
	else: 
		# start playing the dance stop animation
		shine_get.disappear()
		character.shine_kill = false
		character.anim_player.play("shine_dance_stop")
		character.anim_player.connect("animation_finished", self, "restore_control", [character], CONNECT_ONESHOT)
		character.anim_player.connect("animation_finished", self, "emit_signal", ["shine_dance_end"], CONNECT_ONESHOT)

# warning-ignore:shadowed_variable
func restore_control(_animation: String, character) -> void:
	# bad code sorry
	yield(get_tree().create_timer(0.2), "timeout")

	# re-enable mode switching if in the editor test mode
	if Singleton.ModeSwitcher.visible:
		Singleton.ModeSwitcher.is_switching = false 

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
	character.shine_cutscene = false
	var timer_manager = get_node("/root").get_node("Player").get_timer_manager()
	timer_manager.pause_resume_timer("area_timer", false)
	
	# to prevent cheese on other shine time scores
	CurrentLevelData.unpause_time_score()
	CurrentLevelData.time_score = score_from_before
	
	Singleton.Music.stop_temporary_music()
