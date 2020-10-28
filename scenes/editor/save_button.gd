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
	
	self_modulate = lerp(self_modulate, Color(1.0, 0.4, 0.4) if CurrentLevelData.unsaved_editor_changes else Color(1.0, 1.0, 1.0), delta * 3 if CurrentLevelData.unsaved_editor_changes else delta * 10)

func _pressed():
	click_sound.play()

	if SavedLevels.selected_level != -1:
		SavedLevels.levels[SavedLevels.selected_level] = LevelInfo.new(CurrentLevelData.level_data.get_encoded_level_data())
		var _error_code = SavedLevels.save_level_by_index(SavedLevels.selected_level)

		CurrentLevelData.unsaved_editor_changes = false

