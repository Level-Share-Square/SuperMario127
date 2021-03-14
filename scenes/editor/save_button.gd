extends TextureButton

export var window : NodePath
onready var window_node = get_node(window)
onready var hover_sound = $HoverSound
onready var click_sound = $ClickSound
var last_hovered = false

func _process(delta):
	if is_hovered() and !last_hovered:
		hover_sound.play()
	last_hovered = is_hovered()
	
	self_modulate = lerp(self_modulate, Color(1.0, 0.4, 0.4) if Singleton.CurrentLevelData.unsaved_editor_changes else Color(1.0, 1.0, 1.0), delta * 3 if Singleton.CurrentLevelData.unsaved_editor_changes else delta * 10)

func _pressed():
	click_sound.play()

	if Singleton.SavedLevels.selected_level != -1:
		Singleton.SavedLevels.levels[Singleton.SavedLevels.selected_level] = LevelInfo.new(Singleton.CurrentLevelData.level_data.get_encoded_level_data())
		var _error_code = Singleton.SavedLevels.save_level_by_index(Singleton.SavedLevels.selected_level)

		Singleton.CurrentLevelData.unsaved_editor_changes = false

