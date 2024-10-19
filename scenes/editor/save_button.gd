extends TextureButton

export var window : NodePath
onready var window_node = get_node(window)
onready var hover_sound = $HoverSound
onready var click_sound = $ClickSound
var last_hovered = false

func _ready():
	connect("gui_input", self, "on_input")

func _process(delta):
	if is_hovered() and !last_hovered:
		hover_sound.play()
	last_hovered = is_hovered()
	
	self_modulate = lerp(self_modulate, Color(1.0, 0.4, 0.4) if Singleton.CurrentLevelData.unsaved_editor_changes else Color(1.0, 1.0, 1.0), delta * 3 if Singleton.CurrentLevelData.unsaved_editor_changes else delta * 10)

func _pressed():
	click_sound.play()
	
	var editor: Node = get_owner()
	editor.sync_pinned_items()
	
	var file_path = level_list_util.get_level_file_path(
		Singleton.CurrentLevelData.level_id, Singleton.CurrentLevelData.working_folder
	)
	level_list_util.save_level_code_file(
		Singleton.CurrentLevelData.level_data.get_encoded_level_data(), 
		file_path
	)
	
	var save_path = level_list_util.get_level_save_path(
		Singleton.CurrentLevelData.level_id, Singleton.CurrentLevelData.working_folder
	)
	if level_list_util.file_exists(save_path):
		level_list_util.delete_file(save_path)

	Singleton.CurrentLevelData.unsaved_editor_changes = false
		
func on_input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == BUTTON_RIGHT:
			$"../AutosaveWINDOW".open()

