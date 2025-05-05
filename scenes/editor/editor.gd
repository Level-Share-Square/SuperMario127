class_name Editor
extends LevelDataLoader


const mode: int = 1

var placed_item_property = null


func _ready():
	#this is to dynamically update the framerate
	_update_editor_framerate()
	
	Engine.iterations_per_second = 60
	# reset these to 0 since they get incremented by the loading in process every time
	Singleton.CurrentLevelData.next_shine_id = 0
	Singleton.CurrentLevelData.next_star_coin_id = 0
	Singleton.CheckpointSaved.reset()
	
	var data = Singleton.CurrentLevelData.level_data
	load_in(data, data.areas[Singleton.CurrentLevelData.area])
	
	# if the mode switch button is invisible then the editor hasn't been readyed for the first time yet
	# (editor _ready() gets called every time a mode switch happens)
	# if the button is invisible and we're in the editor scene, we know it's time to setup the editor for the first time
	if Singleton.ModeSwitcher.get_node("ModeSwitcherButton").invisible:
		# enable the mode switching button since we're using the editor
		Singleton.ModeSwitcher.get_node("ModeSwitcherButton").change_button_state(true)
		Singleton.Music.play() # needed as the music no longer plays by default
	
		# make sure the mode switcher button is set to have the play button as it's visual
		Singleton.ModeSwitcher.get_node("ModeSwitcherButton").change_visuals(0)
	
		Singleton.CurrentLevelData.unsaved_editor_changes = false


func _process(delta):
	pass


#func _input(event):
#	if event is InputEventKey:
#		print(event.scancode)
#		print(event.physical_scancode)


func _update_editor_framerate():
	fps_util._update_framerate(true)
	get_tree().create_timer(1.0).connect("timeout", self, "_update_editor_framerate")


func switch_scenes():
	var _change_scene = get_tree().change_scene("res://scenes/player/player.tscn")
