extends LevelDataLoader

onready var tick_sound = $SharedSounds/TickSound
onready var tick_end_sound = $SharedSounds/TickEndSound

export var character : NodePath
export var character2 : NodePath
export var camera : NodePath

var mode = 0
var ssc_displayed = true

export var coin_frame : int
const coin_anim_fps = 12
var can_collect_coins : Array

export var switch_timer : float = 0.0
export var sound_timer : float = 0.0

func get_shared_node() -> Node:
	return $Viewports/ViewportContainer/Viewport/World.get_node("Shared")

func _process(_delta):
	coin_frame = (OS.get_ticks_msec() * coin_anim_fps / 1000) % 4

func _physics_process(delta):
	var viewport_rect : Rect2 = get_viewport_rect()
	viewport_rect.size = Vector2(768, 432) * get_node(camera).zoom
	viewport_rect.position = -get_canvas_transform().get_origin()
#	print(viewport_rect)
	get_node("%SharedSounds").saw_sound.handle_saw_sound_position(viewport_rect)
	get_node("%SharedSounds").blaster_sound.handle_blast_sound_position(viewport_rect)
	
	if switch_timer > 0:
		switch_timer -= delta
		sound_timer -= delta
		if sound_timer <= 0:
			if switch_timer > 3:
				tick_sound.play()
			else:
				if !tick_end_sound.playing:
					tick_end_sound.play()
			sound_timer = wrapf(switch_timer, 0, 1.1)
			
		if switch_timer <= 0:
			switch_timer = 0

func _ready():
	sound_timer = wrapf(switch_timer, 0, 1.1)
#	vignette.visible = false
	
	Singleton.CurrentLevelData.enemies_instanced = 0
	Singleton.CurrentLevelData.level_data.vars.reset_counters()
	
	if !Singleton.MiscShared.is_play_reload:
		Singleton.CheckpointSaved.reset()
		Singleton.CurrentLevelData.level_data.vars.init()
	
	if Singleton.CurrentLevelData.level_data.vars.transition_data == []:
		Singleton.CurrentLevelData.area = Singleton.CheckpointSaved.current_area
		Singleton.CurrentLevelData.level_data.vars.reload()
	
	if Singleton.CurrentLevelData.level_data.areas[Singleton.CurrentLevelData.area].settings.timer > 0.00:
		var timer_manager = get_timer_manager()
		timer_manager.add_set_timer("area_timer", Singleton.CurrentLevelData.level_data.areas[Singleton.CurrentLevelData.area].settings.timer, "death", true, true)
#		vignette.visible = true
	
	var data = Singleton.CurrentLevelData.level_data
	load_in(data, data.areas[Singleton.CurrentLevelData.area])
	
	Singleton.Music.character = get_node(character)
	Singleton.Music.character2 = get_node(character2)
	#Singleton.Music.reset_music()
	if !Singleton.Music.playing:
		Singleton.Music.play() # make sure the music will play even if it's stopped prior to loading the player

	can_collect_coins.append(get_node(character))
	if Singleton.PlayerSettings.number_of_players == 2:
		can_collect_coins.append(get_node(character2))
		
	Singleton.CurrentLevelData.level_data.vars.max_red_coins = 0
	Singleton.CurrentLevelData.level_data.vars.max_shine_shards = 0
	Singleton.CurrentLevelData.level_data.vars.max_purple_starbits = 0
	Singleton.CurrentLevelData.level_data.vars.teleporters = []
	Singleton.CurrentLevelData.level_data.vars.liquids = []
	Singleton.CurrentLevelData.level_data.vars.checkpoints = []
	
	Singleton.MiscShared.is_play_reload = true

	yield(get_tree(), "physics_frame")
	Singleton.CurrentLevelData.level_data.vars.max_red_coins = Singleton.CurrentLevelData.get_red_coins_before_area(Singleton.CurrentLevelData.level_data.areas.size())

func _unhandled_input(event):
	if event.is_action_pressed("reload") or event.is_action_pressed("reload_from_start") and !Singleton.SceneTransitions.transitioning and (!Singleton.ModeSwitcher.get_node("ModeSwitcherButton").switching_disabled or Singleton.ModeSwitcher.get_node("ModeSwitcherButton").invisible):
		if event.is_action_pressed("reload_from_start"):
			Singleton.CheckpointSaved.reset()
		if !get_node(character).dead:
			get_node(character).kill("reload")
		elif Singleton.PlayerSettings.number_of_players == 2:
			get_node(character2).kill("reload")
		if Singleton.PlayerSettings.other_player_id != -1:
			var _send_bytes = get_tree().multiplayer.send_bytes(JSON.print(["reload"]).to_ascii())

func switch_scenes():
	if Singleton2.rp == true:
		update_activity()
	elif Singleton2.rp == false:
		if Singleton2.dead == false:
			Discord.queue_free()
			Singleton2.dead = true
		elif Singleton2.dead == true:
			pass
	var _change_scene = get_tree().change_scene("res://scenes/editor/editor.tscn")

func reload_scene():
	GhostArrays.reload = get_tree().reload_current_scene()

func update_activity() -> void:
	var activity = Discord.Activity.new()
	activity.set_type(Discord.ActivityType.Playing)
	activity.set_state("Editing a level")

	var assets = activity.get_assets()
	assets.set_large_image("sm127")
	assets.set_large_text("0.9.0")
	assets.set_small_image("capsule_main")
	assets.set_small_text("ZONE 2 WOOO")
	
	var timestamps = activity.get_timestamps()
	timestamps.set_start(OS.get_unix_time() + 1)

	var result = yield(Discord.activity_manager.update_activity(activity), "result").result
	if result != Discord.Result.Ok:
		printerr(str(result))


func get_characters() -> Array:
	var array: Array = [get_node(character)]
	if Singleton.PlayerSettings.number_of_players == 2:
		array.append(get_node(character2))
	return array


# todo: mayb move this stuff elsewhere?? question mark? ?? ?
const TIMER_ICON := preload("res://scenes/actors/objects/p_switch/icon.png")
func set_switch_timer(new_time: float):
	switch_timer = new_time
	
	if switch_timer <= 0: return
	var timer_manager: Control = $"%TimerManager"
	timer_manager.add_radial_timer("PSwitch", self, "switch_timer", TIMER_ICON)


func get_timer_manager() -> Control:
	var timer_manager: Control = $"%TimerManager"
	return timer_manager
