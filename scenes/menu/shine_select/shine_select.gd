extends CanvasLayer

## nodes
onready var shine_parent: Node2D = $ShineParent
onready var anim_player: AnimationPlayer = $AnimationPlayer
onready var backgrounds: Node2D = $Backgrounds

onready var mission_select_sfx: AudioStreamPlayer = $Sounds/MissionSelect
onready var transition_audio: AudioStreamPlayer = $Sounds/TransitionAudio
onready var letsa_go_sfx: Node = $Sounds/LetsaGo
onready var letsa_go_sfx_2: Node = $Sounds/LetsaGo2
onready var back = $VBoxContainer/BottomBar/MarginContainer/Back

onready var level_title: Label = $"%LevelTitle"
onready var level_title_backing: Label = $"%LevelTitleBacking"

onready var fludds = $"%FLUDD"

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
#	for fludd in fludds.get_children():
#		if CurrentLevelData..activated_fludds[fludd.get_index()]:
#			fludd.visible = true
#			fludd.connect("pressed", self, "_on_fludd_pressed", [fludd.name])
#		else:
#			fludd.visible = false
	get_tree().paused = false
	
	mission_select_sfx.play()
	
	level_title.text = level_metadata.level_name
	level_title_backing.text = level_title.text
	
	backgrounds.load_in()
	backgrounds.do_auto_scroll = true
	
	anim_player.play_backwards("transition")

func start_level():
	var mission_data: MissionData = CurrentLevelData.level_metadata.collectible_data.mission_data[shine_parent.selected_shine_index]
	CurrentLevelData.level_transition_data = {
		"target_area": mission_data.spawn_area_id,
		"target_tag": mission_data.spawn_teleporter_tag
	} 
#	print(CurrentLevelData.current_area)
	
	if not shine_parent.can_interact: return
	shine_parent.can_interact = false
	
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

#func _on_fludd_pressed(fludd: String):
#	level_info.chosen_fludd = fludd
