extends CanvasLayer


const SCROLL_SPEED: float = 200.0
const MARIO_FRAMES: SpriteFrames = preload("res://scenes/actors/mario/animation_frames.tres")
const LUIGI_FRAMES: SpriteFrames = preload("res://scenes/actors/mario/luigi_frames.tres")
const MARIO_HOVER_FRAMES: SpriteFrames = preload("res://scenes/actors/mario/nozzles/hover_frames.tres")
const LUIGI_HOVER_FRAMES: SpriteFrames = preload("res://scenes/actors/mario/nozzles/hover_frames_luigi.tres")
const MARIO_ROCKET_FRAMES: SpriteFrames = preload("res://scenes/actors/mario/nozzles/rocket_frames.tres")
const LUIGI_ROCKET_FRAMES: SpriteFrames = preload("res://scenes/actors/mario/nozzles/rocket_frames_luigi.tres")
const MARIO_TURBO_FRAMES: SpriteFrames = preload("res://scenes/actors/mario/nozzles/turbo_frames.tres")
const LUIGI_TURBO_FRAMES: SpriteFrames = preload("res://scenes/actors/mario/nozzles/turbo_frames_luigi.tres")

## nodes
onready var shine_parent: Node2D = $ShineParent
onready var anim_player: AnimationPlayer = $AnimationPlayer
onready var backgrounds: Node2D = $Backgrounds

onready var nozzle_switch_sound = $"%NozzleSwitchSound"
onready var mission_select_sfx: AudioStreamPlayer = $Sounds/MissionSelect
onready var transition_audio: AudioStreamPlayer = $Sounds/TransitionAudio
onready var letsa_go_sfx: Node = $Sounds/LetsaGo
onready var letsa_go_sfx_2: Node = $Sounds/LetsaGo2
onready var back = $VBoxContainer/BottomBar/MarginContainer/Back

onready var level_title: Label = $"%LevelTitle"
onready var level_title_backing: Label = $"%LevelTitleBacking"

onready var player_anim_player = $"%PlayerAnimPlayer"
onready var fludds = $"%FLUDD"

onready var player_sprite = $"%PlayerSprite"
onready var player_shadow = $"%PlayerSprite/Shadow"
onready var player_fludd = $"%PlayerSprite/Fludd"
onready var player_fludd_shadow = $"%PlayerSprite/Fludd/Shadow"


## level data
onready var level_metadata: LevelMetadata = CurrentLevelData.level_metadata

# other
var backing_out: bool = false


func back():
	if not backing_out:
		anim_player.play("transition")
		Singleton.SceneSwitcher.quit_level()
		backing_out = true


func _ready():
	var fludd_index: int = 0
	for fludd in fludds.get_children():
		if fludd.name == "Empty":
			fludd.connect("pressed", self, "select_nozzle", [""])
			continue
		
		if not fludd.name in CurrentLevelData.level_metadata.collectible_data.persistent_nozzles:
			fludd.disabled = true
			fludd.get_node("Nozzle").modulate.a = 0.5
			fludd.get_node("Corruption").show()
		elif not CurrentLevelData.save_data._activated_fludds[fludd_index]:
			fludd.disabled = true
			fludd.get_node("Nozzle").modulate.a = 0.5
		else:
			fludd.connect("pressed", self, "select_nozzle", [fludd.name])
		
		fludd_index += 1
	
	update_character()
	get_tree().paused = false
	
	mission_select_sfx.play()
	
	level_title.text = level_metadata.level_name
	level_title_backing.text = level_title.text
	
	backgrounds.auto_scroll_override = true
	backgrounds.auto_scroll_speed = SCROLL_SPEED
	backgrounds.load_in()
	
	anim_player.play_backwards("transition")

func start_level():
	var mission_data: MissionData = CurrentLevelData.level_metadata.collectible_data.mission_data[shine_parent.selected_shine_index]
	CurrentLevelData.level_transition_data = {
		"target_area": mission_data.spawn_area_id,
		"target_tag": mission_data.spawn_teleporter_tag
	}
	
	if not shine_parent.can_interact: return
	shine_parent.can_interact = false
	
	player_anim_player.play("start")
	transition_audio.play()
	letsa_go_sfx.play()
	
	get_tree().call_group("shine_sprites", "start_pressed_animation")
	
	CurrentLevelData.current_mission_id = mission_data.mission_uuid
	CurrentLevelData.current_mission = mission_data
	
	# levels screen is supposed to set the CurrentLevelData before changing to the shine select screen
	# so we'll assume it's safe to just go straight to the player scene 
	anim_player.play("transition")
	anim_player.connect("animation_finished", self, "animation_finished", [], CONNECT_DEFERRED | CONNECT_ONESHOT)

# kinda lame that you HAVE to use the arguments a signal gives always 
func animation_finished(_animation_name: String):
	Singleton.SceneSwitcher.force_start_level()

func select_nozzle(nozzle: String):
	if nozzle != CurrentLevelData.starting_nozzle:
		nozzle_switch_sound.play()
	CurrentLevelData.starting_nozzle = nozzle
	update_character()

func update_character() -> void:
	var palette_material: ShaderMaterial = preload("res://scenes/actors/mario/materials/palette_swap.tres").duplicate()
	var cur_char: int = Singleton.PlayerSettings.player1_character
	var char_folder: String = Character.CHAR_NAMES[cur_char].to_lower()
	var cur_palette: String = LocalSettings.load_setting("General", "char_palette", "default")
	palette_material.set_shader_param("palette_in", load(Character.PALETTES_PATH % [char_folder, "default"]))
	palette_material.set_shader_param("palette_out", load(Character.PALETTES_PATH % [char_folder, cur_palette]))
	
	player_sprite.material = palette_material
	player_sprite.frames = MARIO_FRAMES if cur_char == 0 else LUIGI_FRAMES
	player_shadow.frames = MARIO_FRAMES if cur_char == 0 else LUIGI_FRAMES
	
	if CurrentLevelData.starting_nozzle == "":
		player_fludd.hide()
	else:
		var char_name: String = "MARIO" if cur_char == 0 else "LUIGI"
		var nozzle_name: String = CurrentLevelData.starting_nozzle.replace("Nozzle", "").to_upper()
		player_fludd.frames = self["%s_%s_FRAMES" % [char_name, nozzle_name]]
		player_fludd.show()
		player_fludd_shadow.frames = player_fludd.frames
