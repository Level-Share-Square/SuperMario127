extends Button

export var window_path : NodePath
onready var window_node = get_node(window_path)

export var text_edit_path : NodePath
onready var text_edit_node = get_node(text_edit_path)

onready var hover_sound = $HoverSound
onready var click_sound = $ClickSound

var last_hovered = false

func _pressed():
	Singleton.ActionManager.clear_history()
	click_sound.play()
	focus_mode = 0
	if level_code_util.is_valid(text_edit_node.text):
		var level_data = LevelData.new()
		level_data.load_in(text_edit_node.text)
		Singleton.CurrentLevelData.level_data = level_data
		var _reload = get_tree().reload_current_scene()
		get_tree().root.get_node("mode_switcher").layer = 127
		
func update_text():
	text_edit_node.text = Singleton.CurrentLevelData.level_data.get_encoded_level_data()
	
func _ready():
	var _connect = window_node.connect("window_opened", self, "update_text")
	yield(get_tree().create_timer(0.1), "timeout")

func _process(_delta):
	if is_hovered() and !last_hovered:
		hover_sound.play()
	last_hovered = is_hovered()
