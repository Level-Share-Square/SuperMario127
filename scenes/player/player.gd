class_name LevelPlayer
extends LevelDataLoader

const mode = 0
const coin_anim_fps = 12

onready var tick_sound = $SharedSounds/TickSound
onready var tick_end_sound = $SharedSounds/TickEndSound

export var character: NodePath
export var camera: NodePath
export var shared: NodePath
export var backgrounds: NodePath

var ssc_displayed = true

var can_collect_coins : Array

export var switch_timer : float = 0.0
export var sound_timer : float = 0.0


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

	CurrentLevelData.enemies_instanced = 0
	CurrentLevelData.vars.reset_counters()
	
	if !Singleton.MiscShared.is_play_reload:
		CurrentLevelData.checkpoint_data.reset()
		CurrentLevelData.vars.init()
	
	if CurrentLevelData.vars.transition_data.empty():
		if CurrentLevelData.checkpoint_data.current_checkpoint_id != -1:
			CurrentLevelData.switch_to_area(CurrentLevelData.checkpoint_data.current_area)
		CurrentLevelData.vars.reload()
	
	if CurrentLevelData.current_area.header.timer > 0.00:
		var timer_manager = get_timer_manager()
		timer_manager.add_set_timer("area_timer", CurrentLevelData.current_area.header.timer, "death", true, true)
#		vignette.visible = true
	
	load_in()
	
	Singleton.Music.character = get_node(character)
	#Singleton.Music.reset_music()
	if !Singleton.Music.playing:
		Singleton.Music.play() # make sure the music will play even if it's stopped prior to loading the player
	
	can_collect_coins.append(get_node(character))
	
	
	var player_char = get_node(character)
	player_char.character = Singleton.PlayerSettings.player1_character
	player_char.number_of_players = Singleton.PlayerSettings.number_of_players
	for object in CurrentLevelData.current_area.get_objects_on_ground():
		if object.metadata.type_id == 0:
			player_char.spawn_pos = object.metadata.position
	
	Singleton.MiscShared.is_play_reload = true
	get_tree().paused = false
	
	yield(get_tree(), "physics_frame")
#	CurrentLevelData.vars.max_red_coins = CurrentLevelData.get_red_coins_before_area(CurrentLevelData.area_headers.size())


func _unhandled_input(event):
	if event.is_action_pressed("reload") or event.is_action_pressed("reload_from_start") and !SceneTransitions.transitioning and (!Singleton.ModeSwitcher.is_switching or not Singleton.ModeSwitcher.visible):
		if event.is_action_pressed("reload_from_start"):
			CurrentLevelData.checkpoint_data.reset()
		if !get_node(character).dead:
			get_node(character).kill("reload")
		if Singleton.PlayerSettings.other_player_id != -1:
			var _send_bytes = get_tree().multiplayer.send_bytes(JSON.print(["reload"]).to_ascii())

func switch_scenes():
	if LocalSettings.load_setting("General", "rich_presence", true):
		update_activity()
	else:
		Discord.set_rich_presence_enabled(false)
	var _change_scene = get_tree().change_scene("res://scenes/editor/editor.tscn")


func reload_scene():
	get_tree().reload_current_scene()


func update_activity() -> void:
	Discord.set_playing("Editing a level")


func get_shared() -> LevelShared:
	return get_node(shared) as LevelShared


func get_characters() -> Array:
	var array: Array = [get_node(character)]
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
