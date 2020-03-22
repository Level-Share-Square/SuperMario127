extends TextureButton

onready var tween = $Tween
onready var tween_hover = $TweenHover
onready var tween_coin = $TweenCoin
onready var tween_disappear = $TweenDisappear
onready var coin = $Coin
onready var sound = $Sound
onready var hover_sound = $HoverSound
onready var fader = get_node("../Fader")
onready var fader_tween = get_node("../Fader/Tween")
var switching_disabled = false
var start_pos
var last_hovered = false

export var texture_play : StreamTexture
export var texture_stop : StreamTexture

func _ready():
	start_pos = self.rect_position

func _physics_process(delta):
	if pressed:
		self.modulate = Color(0.65, 0.65, 0.65)
	elif is_hovered():
		self.modulate = Color(0.85, 0.85, 0.85)
	else:
		self.modulate = Color(1, 1, 1)
		
	if is_hovered() and !last_hovered:
		hover_sound.play()
		tween_hover.interpolate_property(self, "rect_pivot_offset",
			Vector2(60, 300), Vector2(60, 290), 0.075,
			Tween.TRANS_CIRC, Tween.EASE_OUT)
		tween_hover.start()
	if !is_hovered() and last_hovered:
		tween_hover.interpolate_property(self, "rect_pivot_offset",
			Vector2(60, 290), Vector2(60, 300), 0.075,
			Tween.TRANS_CIRC, Tween.EASE_OUT)
		tween_hover.start()
	last_hovered = is_hovered()
		
func _unhandled_input(event):
	if event.is_action_pressed("switch_modes"):
		_pressed()

func _pressed():
	switch()
		
func change_visuals(new_scene):
	self.texture_normal = texture_play if new_scene == 0 else texture_stop

func switch():
	if !switching_disabled:
		sound.play()
		switching_disabled = true
		rect_position = start_pos
		
		tween.interpolate_property(self, "rect_position",
			start_pos, start_pos + Vector2(0, -15), 0.25,
			Tween.TRANS_CIRC, Tween.EASE_OUT)
		tween.start()
		
		tween_coin.interpolate_property(coin, "position",
			Vector2(0, 0), Vector2(0, -200), 0.25,
			Tween.TRANS_CIRC, Tween.EASE_OUT)
		tween_coin.start()
		
		tween_disappear.interpolate_property(coin, "modulate",
			Color(1, 1, 1, 1), Color(1, 1, 1, 0), 0.23,
			Tween.TRANS_CIRC, Tween.EASE_IN)
		tween_disappear.start()
		
		fader.visible = true
		fader_tween.interpolate_property(fader, "modulate",
			Color(1, 1, 1, 0), Color(1, 1, 1, 1), 0.20,
			Tween.TRANS_LINEAR, Tween.EASE_OUT)
		fader_tween.start()
		
		yield(tween, "tween_completed")
		music.loading = true
		yield(get_tree().create_timer(0.3), "timeout")
		
		var new_scene = get_tree().get_current_scene().mode
		get_tree().get_current_scene().switch_scenes()
		change_visuals(new_scene)
		
		yield(get_tree().create_timer(0.1), "timeout")
		music.loading = false
		
		tween.interpolate_property(self, "rect_position",
			start_pos + Vector2(0, -15), start_pos, 0.25,
			Tween.TRANS_CIRC, Tween.EASE_OUT)
		tween.start()
		
		fader_tween.interpolate_property(fader, "modulate",
			Color(1, 1, 1, 1), Color(1, 1, 1, 0), 0.20,
			Tween.TRANS_LINEAR, Tween.EASE_OUT)
		fader_tween.start()
		
		yield(tween, "tween_completed")
		
		fader.visible = false
		rect_position = start_pos
		switching_disabled = false
