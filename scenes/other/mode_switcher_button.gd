extends TextureButton

onready var top_part = $TopPart
onready var tween = $Tween
onready var tween_bottom = $TweenBottom
onready var sound = $Sound
onready var fader = get_node("../Fader")
onready var fader_tween = get_node("../Fader/Tween")
var pressing_disabled = false

export var bottom_texture_play : StreamTexture
export var top_texture_play : StreamTexture

export var bottom_texture_stop : StreamTexture
export var top_texture_stop : StreamTexture

func _process(delta):
	if pressed:
		self.modulate = Color(0.65, 0.65, 0.65)
	elif is_hovered():
		self.modulate = Color(0.85, 0.85, 0.85)
	else:
		self.modulate = Color(1, 1, 1)

func _pressed():
	if !pressing_disabled:
		pressing_disabled = true
		rect_rotation = 0
		top_part.rect_rotation = 0
		
		tween.interpolate_property(top_part, "rect_rotation",
			0, -45, 0.35,
			Tween.TRANS_CIRC, Tween.EASE_OUT)
		tween.start()
		tween_bottom.interpolate_property(self, "rect_rotation",
			0, -10, 0.35,
			Tween.TRANS_CIRC, Tween.EASE_OUT)
		tween_bottom.start()
		
		fader.visible = true
		fader_tween.interpolate_property(fader, "modulate",
			Color(1, 1, 1, 0), Color(1, 1, 1, 1), 0.35,
			Tween.TRANS_LINEAR, Tween.EASE_OUT)
		fader_tween.start()
		
		yield(tween, "tween_completed")
		
		sound.play()
		var scene_path = "res://scenes/player/player.tscn" if get_tree().get_current_scene().get_name() == "Editor" else "res://scenes/editor/editor.tscn" 
		get_tree().change_scene(scene_path)
		self.texture_normal = bottom_texture_stop if get_tree().get_current_scene().get_name() == "Editor" else bottom_texture_play
		top_part.texture = top_texture_stop if get_tree().get_current_scene().get_name() == "Editor" else top_texture_play
		
		tween.interpolate_property(top_part, "rect_rotation",
			-45, 0, 0.20,
			Tween.TRANS_EXPO, Tween.EASE_OUT)
		tween.start()
		tween_bottom.interpolate_property(self, "rect_rotation",
			-10, 0, 0.35,
			Tween.TRANS_BACK, Tween.EASE_OUT)
		tween_bottom.start()
		
		fader_tween.interpolate_property(fader, "modulate",
			Color(1, 1, 1, 1), Color(1, 1, 1, 0), 0.20,
			Tween.TRANS_LINEAR, Tween.EASE_OUT)
		fader_tween.start()
		
		yield(tween, "tween_completed")
		
		fader.visible = false
		rect_rotation = 0
		top_part.rect_rotation = 0
		pressing_disabled = false
