extends TextureButton

onready var tween : Tween = $Tween
onready var tween_hover : Tween = $TweenHover
onready var tween_coin : Tween = $TweenCoin
onready var tween_disappear : Tween = $TweenDisappear
onready var coin : Sprite = $Coin
onready var sound : AudioStreamPlayer = $Sound
onready var hover_sound : AudioStreamPlayer = $HoverSound
onready var fader : ColorRect = get_node("../Fader")
onready var fader_tween : Tween = get_node("../Fader/Tween")
var switching_disabled := true
var start_pos : Vector2
var last_hovered := false
var last_paused := false
var invisible := true

var playtesting := false

export var texture_play : StreamTexture
export var texture_stop : StreamTexture

export var edit_pos : Vector2
export var play_pos : Vector2

func _ready() -> void:
	start_pos = self.rect_position

func _physics_process(_delta : float) -> void:
	
	if !get_tree().paused and !invisible:
		if last_paused:
			visible = true
		
		if pressed:
			self.modulate = Color(0.65, 0.65, 0.65)
		elif is_hovered():
			self.modulate = Color(0.85, 0.85, 0.85)
		else:
			self.modulate = Color(1, 1, 1)
			
		if is_hovered() and !last_hovered:
			hover_sound.play()
			# warning-ignore: return_value_discarded
			tween_hover.interpolate_property(self, "rect_pivot_offset",
				Vector2(60, 300), Vector2(60, 290), 0.075,
				Tween.TRANS_CIRC, Tween.EASE_OUT)
			# warning-ignore: return_value_discarded
			tween_hover.start()
		if !is_hovered() and last_hovered:
			# warning-ignore: return_value_discarded
			tween_hover.interpolate_property(self, "rect_pivot_offset",
				Vector2(60, 290), Vector2(60, 300), 0.075,
				Tween.TRANS_CIRC, Tween.EASE_OUT)
			# warning-ignore: return_value_discarded
			tween_hover.start()
		last_hovered = is_hovered()
		last_paused = false
	else:
		visible = false
		last_paused = true
		
func _unhandled_input(event : InputEvent) -> void:
	if event.is_action_pressed("switch_modes"):
		_pressed()

func _pressed() -> void:
	switch()
		
func change_visuals(new_scene_mode : int) -> void:
	self.texture_normal = texture_play if new_scene_mode == 0 else texture_stop

func switch() -> void:
	get_parent().offset.y = 0
	if get_parent().layer != 99 and !switching_disabled and !get_tree().paused and !Singleton.SceneTransitions.transitioning:
		Singleton.Music.reset_music()
		Singleton.Music.stop_temporary_music(1, 1)

		Singleton.ActionManager.clear_history()
		
		#Singleton.CurrentLevelData.area = 0
		Singleton.CheckpointSaved.current_area = Singleton.CurrentLevelData.area
		Singleton.CurrentLevelData.level_data.vars.reload()
		Singleton.CurrentLevelData.enemies_instanced = 0
		Singleton.MiscShared.is_play_reload = true
		
		sound.play()
		switching_disabled = true
		rect_position = start_pos
		
		# warning-ignore: return_value_discarded
		tween.interpolate_property(self, "rect_position",
			start_pos, start_pos + Vector2(0, -15), 0.25,
			Tween.TRANS_CIRC, Tween.EASE_OUT)
		# warning-ignore: return_value_discarded
		tween.start()
		
		# warning-ignore: return_value_discarded
		tween_coin.interpolate_property(coin, "position",
			Vector2(0, 0), Vector2(0, -200), 0.25,
			Tween.TRANS_CIRC, Tween.EASE_OUT)
		# warning-ignore: return_value_discarded
		tween_coin.start()
		
		# warning-ignore: return_value_discarded
		tween_disappear.interpolate_property(coin, "modulate",
			Color(1, 1, 1, 1), Color(1, 1, 1, 0), 0.23,
			Tween.TRANS_CIRC, Tween.EASE_IN)
		# warning-ignore: return_value_discarded
		tween_disappear.start()
		
		fader.visible = true
		# warning-ignore: return_value_discarded
		fader_tween.interpolate_property(fader, "modulate",
			Color(1, 1, 1, 0), Color(1, 1, 1, 1), 0.20,
			Tween.TRANS_LINEAR, Tween.EASE_OUT)
		# warning-ignore: return_value_discarded
		fader_tween.start()
		
		yield(tween, "tween_completed")
		
		yield(get_tree().create_timer(0.3), "timeout")
		get_tree().paused = false
		Singleton.CurrentLevelData.level_data.vars = LevelVars.new() # Reset vars
		Singleton.CurrentLevelData.level_data.vars.init()
		
		get_tree().get_current_scene().switch_scenes()
		var new_scene_mode = get_tree().get_current_scene().mode
		if new_scene_mode == 0:
			playtesting = false
		elif new_scene_mode == 1:
			playtesting = true
		change_visuals(new_scene_mode)
		
		yield(get_tree().create_timer(0.1), "timeout")
		
		# warning-ignore: return_value_discarded
		tween.interpolate_property(self, "rect_position",
			start_pos + Vector2(0, -15), start_pos, 0.25,
			Tween.TRANS_CIRC, Tween.EASE_OUT)
		# warning-ignore: return_value_discarded
		tween.start()
		
		# warning-ignore: return_value_discarded
		fader_tween.interpolate_property(fader, "modulate",
			Color(1, 1, 1, 1), Color(1, 1, 1, 0), 0.20,
			Tween.TRANS_LINEAR, Tween.EASE_OUT)
		# warning-ignore: return_value_discarded
		fader_tween.start()
		
		yield(tween, "tween_completed")
		
		fader.visible = false
		rect_position = start_pos
		switching_disabled = false

func change_button_state(is_enabled : bool) -> void:
	invisible = !is_enabled
	switching_disabled = !is_enabled
