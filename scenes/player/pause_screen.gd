extends Control

export var darken_color : Color

export var character_node_path : NodePath
onready var character_node = get_node(character_node_path)

export var character2_node_path : NodePath
onready var character2_node = get_node(character2_node_path)

onready var topbar = $Top

onready var bottombar = $Bottom
onready var resume_button = $Bottom/Buttons/ResumeButton
onready var retry_button = $Bottom/Buttons/RetryButton
onready var quit_button = $Bottom/Buttons/QuitButton
onready var darken = $Darken

onready var shine_info = $ShineInfo
onready var multiplayer_options = $MultiplayerOptions
onready var controls_options = $ControlsOptions

onready var fade_tween = $TweenFade
onready var topbar_tween = $TweenTopbar
onready var bottombar_tween = $TweenBottombar
onready var info_tween = $TweenShineInfo

export var chat_path : NodePath
onready var chat_node = get_node(chat_path)

var paused := false

func _ready():
	# You want it to be visible for editing, but that causes a bug, which this fixes
	visible = false

	var _connect = resume_button.connect("pressed", self, "toggle_pause")
	_connect = retry_button.connect("pressed", self, "retry")
	_connect = quit_button.connect("pressed", self, "quit_to_menu")
	FocusCheck.is_ui_focused = false
	
	darken.modulate = Color(0, 0, 0, 0)
	topbar.rect_position = Vector2(0, -70)
	bottombar.rect_position = Vector2(768, 500)
	shine_info.rect_scale = Vector2(0, 0)

	CurrentLevelData.can_pause = true

	set_process(false)

	update_shine_info()

func _unhandled_input(event):
	if CurrentLevelData.can_pause and event.is_action_pressed("pause") and !(character_node.dead or (PlayerSettings.number_of_players != 1 and character2_node.dead)):
		toggle_pause()

func toggle_pause():
	var is_not_transitioning : bool = !scene_transitions.transitioning
	# if the mode switcher button is invisible, then we're not in the editor at all
	var is_not_switching_modes : bool = !mode_switcher.get_node("ModeSwitcherButton").switching_disabled or mode_switcher.get_node("ModeSwitcherButton").invisible
	if is_not_transitioning and is_not_switching_modes and !PhotoMode.enabled and paused == get_tree().paused:
		if !shine_info.visible:
			$ControlsOptions.reset() # for resetting the Wait... state
			$ControlsOptions/ControlBindingWindow/Contents/ScrollContainer/BindingBoxContainer.reset()
			$ControlsOptions/ControlBindingWindow.close()
			SettingsSaver.save($MultiplayerOptions)
			if controls_options.visible:
				controls_options.visible = false
				shine_info.visible = true
			else:
				multiplayer_options.visible = false
				shine_info.visible = true
		resume_button.focus_mode = 0
		
		CurrentLevelData.can_pause = false
		get_tree().paused = true if !self.visible and PlayerSettings.other_player_id == -1 else false
		paused = get_tree().paused
		# if we're visible and toggling pause, that means we need to fade out back to gameplay
		if self.visible:
			FocusCheck.is_ui_focused = false
			chat_node.visible = true
			fade_tween.interpolate_property(darken, "modulate",
			null, Color(0, 0, 0, 0), 0.20,
			Tween.TRANS_LINEAR, Tween.EASE_OUT)
			fade_tween.start()
			
			topbar_tween.interpolate_property(topbar, "rect_position",
			topbar.rect_position, Vector2(0, -70), 0.20,
			Tween.TRANS_QUAD, Tween.EASE_IN)
			topbar_tween.start()
			
			bottombar_tween.interpolate_property(bottombar, "rect_position",
			bottombar.rect_position, Vector2(768, 500), 0.20,
			Tween.TRANS_QUAD, Tween.EASE_IN)
			bottombar_tween.start()
			
			info_tween.interpolate_property(shine_info, "rect_scale",
			shine_info.rect_scale, Vector2(0, 0), 0.20,
			Tween.TRANS_QUAD, Tween.EASE_IN)
			info_tween.start()
			
			yield(fade_tween, "tween_completed")
			
			self.visible = false
			CurrentLevelData.can_pause = true

			# disable process at the end of the transition so the time score updates during it
			set_process(false)
		else:
			# enable process before the transition starts so the time score updates during it
			set_process(true)

			FocusCheck.is_ui_focused = true
			self.visible = true
			chat_node.visible = false
			fade_tween.interpolate_property(darken, "modulate",
			null, darken_color, 0.20,
			Tween.TRANS_LINEAR, Tween.EASE_OUT)
			fade_tween.start()
			
			topbar_tween.interpolate_property(topbar, "rect_position",
			topbar.rect_position, Vector2(0, 0), 0.20,
			Tween.TRANS_CIRC, Tween.EASE_OUT)
			topbar_tween.start()
			
			bottombar_tween.interpolate_property(bottombar, "rect_position",
			bottombar.rect_position, Vector2(768, 400), 0.20,
			Tween.TRANS_CIRC, Tween.EASE_OUT)
			bottombar_tween.start()
			
			info_tween.interpolate_property(shine_info, "rect_scale",
			shine_info.rect_scale, Vector2(1, 1), 0.20,
			Tween.TRANS_CIRC, Tween.EASE_OUT)
			info_tween.start()
			
			yield(fade_tween, "tween_completed")
			
			CurrentLevelData.can_pause = true
	
func retry():
	SettingsSaver.save($MultiplayerOptions)
	retry_button.focus_mode = 0
	if !character_node.dead:
		character_node.kill("reload")
	else:
		character2_node.kill("reload")

func quit_to_menu() -> void:
	# music is stopped while paused, but there's a frame where it starts playing again after the transition, just kill it here to stop that
	music.change_song(music.last_song, 0)
	MenuVariables.quit_to_menu_with_transition("levels_screen")

func update_shine_info():
	var level_info = SavedLevels.levels[SavedLevels.selected_level]
	if level_info.selected_shine == -1:
		return
	var selected_shine_info = level_info.shine_details[level_info.selected_shine]

	var level_name : Label = shine_info.get_node("LevelName")
	var level_name_backing : Label = shine_info.get_node("LevelName/LevelNameBacking")
	var shine_description : RichTextLabel = shine_info.get_node("ShineDescription")
	var shine_name : RichTextLabel = shine_info.get_node("ShineName")

	level_name.text = level_info.level_name 
	level_name_backing.text = level_info.level_name
	shine_description.bbcode_text = "[center]%s[/center]" % selected_shine_info["description"] 
	shine_name.bbcode_text = "[center]%s[/center]" % selected_shine_info["title"]
