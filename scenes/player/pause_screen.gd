extends Control

export var darken_color : Color

export var character_node_path : NodePath
onready var character_node = get_node(character_node_path)

export var character2_node_path : NodePath
onready var character2_node = get_node(character2_node_path)

onready var topbar = $Top

onready var bottombar = $Bottom
onready var resume_button = $Bottom/ResumeButton
onready var retry_button = $Bottom/RetryButton
onready var darken = $Darken

onready var shine_info = $ShineInfo
onready var multiplayer_options = $MultiplayerOptions

onready var fade_tween = $TweenFade
onready var topbar_tween = $TweenTopbar
onready var bottombar_tween = $TweenBottombar
onready var info_tween = $TweenShineInfo

export var chat_path : NodePath
onready var chat_node = get_node(chat_path)

func _unhandled_input(event):
	if event.is_action_pressed("pause") and !(character_node.dead and (PlayerSettings.number_of_players != 1 and character2_node.dead)):
		toggle_pause()

func toggle_pause():
	if !PhotoMode.enabled:
		if !shine_info.visible:
			multiplayer_options.visible = false
			shine_info.visible = true
		resume_button.focus_mode = 0
		
		get_tree().paused = true if !self.visible and PlayerSettings.other_player_id == -1 else false
		if self.visible:
			FocusCheck.is_ui_focused = false
			chat_node.visible = true
			fade_tween.interpolate_property(darken, "modulate",
			darken_color, Color(0, 0, 0, 0), 0.20,
			Tween.TRANS_LINEAR, Tween.EASE_OUT)
			fade_tween.start()
			
			topbar_tween.interpolate_property(topbar, "rect_position",
			Vector2(0, 0), Vector2(0, -70), 0.20,
			Tween.TRANS_QUAD, Tween.EASE_IN)
			topbar_tween.start()
			
			bottombar_tween.interpolate_property(bottombar, "rect_position",
			Vector2(768, 400), Vector2(768, 500), 0.20,
			Tween.TRANS_QUAD, Tween.EASE_IN)
			bottombar_tween.start()
			
			info_tween.interpolate_property(shine_info, "rect_scale",
			Vector2(1, 1), Vector2(0, 0), 0.20,
			Tween.TRANS_QUAD, Tween.EASE_IN)
			info_tween.start()
			
			yield(fade_tween, "tween_completed")
			self.visible = false
		else:
			FocusCheck.is_ui_focused = true
			self.visible = true
			chat_node.visible = false
			fade_tween.interpolate_property(darken, "modulate",
			Color(0, 0, 0, 0), darken_color, 0.20,
			Tween.TRANS_LINEAR, Tween.EASE_OUT)
			fade_tween.start()
			
			topbar_tween.interpolate_property(topbar, "rect_position",
			Vector2(0, -70), Vector2(0, 0), 0.20,
			Tween.TRANS_CIRC, Tween.EASE_OUT)
			topbar_tween.start()
			
			bottombar_tween.interpolate_property(bottombar, "rect_position",
			Vector2(768, 500), Vector2(768, 400), 0.20,
			Tween.TRANS_CIRC, Tween.EASE_OUT)
			bottombar_tween.start()
			
			info_tween.interpolate_property(shine_info, "rect_scale",
			Vector2(0, 0), Vector2(1, 1), 0.20,
			Tween.TRANS_CIRC, Tween.EASE_OUT)
			info_tween.start()
			
			yield(fade_tween, "tween_completed")
	
func retry():
	retry_button.focus_mode = 0
	if !character_node.dead:
		character_node.kill("reload")
	else:
		character2_node.kill("reload")

func _ready():
	var _connect = resume_button.connect("pressed", self, "toggle_pause")
	var _connect2 = retry_button.connect("pressed", self, "retry")
	FocusCheck.is_ui_focused = false
