extends CanvasLayer

## nodes
onready var shine_parent: Node2D = $ShineParent
onready var anim_player: AnimationPlayer = $AnimationPlayer
onready var backgrounds: Node2D = $Backgrounds

onready var mission_select_sfx: AudioStreamPlayer = $Sounds/MissionSelect
onready var transition_audio: AudioStreamPlayer = $Sounds/TransitionAudio
onready var letsa_go_sfx: Node = $Sounds/LetsaGo
onready var letsa_go_sfx_2: Node = $Sounds/LetsaGo2

onready var level_title: Label = get_node("%LevelTitle")
onready var level_title_backing: Label = get_node("%LevelTitleBacking")

## level data
onready var level_info: LevelInfo = Singleton.CurrentLevelData.level_info
onready var level_data: LevelData = Singleton.CurrentLevelData.level_data

func back():
	anim_player.play("transition")
	Singleton.SceneSwitcher.quit_to_menu_with_transition("levels_list")

func _ready():
	mission_select_sfx.play()
	
	level_title.text = level_info.level_name
	level_title_backing.text = level_title.text
	
	backgrounds.load_in(level_data, level_data.areas[0])
	backgrounds.do_auto_scroll = true
	
	anim_player.play_backwards("transition")

func start_level():
	if not shine_parent.can_interact: return
	shine_parent.can_interact = false
	
	transition_audio.play()
	letsa_go_sfx.play()
	if Singleton.PlayerSettings.number_of_players > 1:
		# quick wait before playing P2's voice clip, to make it sound more natural
		yield(get_tree().create_timer(0.035), "timeout")
		
		# we set the array index so the same voice is played for both, and it syncs
		letsa_go_sfx_2.array_index = letsa_go_sfx.array_index
		letsa_go_sfx_2.play()
	
	get_tree().call_group("shine_sprites", "start_pressed_animation")
	
	Singleton.CurrentLevelData.level_info.selected_shine = shine_parent.shine_details_indices[shine_parent.selected_shine_index]
	
	# levels screen is supposed to set the CurrentLevelData before changing to the shine select screen
	# so we'll assume it's safe to just go straight to the player scene 
	anim_player.play("transition")
	anim_player.connect("animation_finished", self, "animation_finished", [], CONNECT_ONESHOT)

# kinda lame that you HAVE to use the arguments a signal gives always 
func animation_finished(_animation_name: String):
	Singleton.SceneSwitcher.force_start_level()
