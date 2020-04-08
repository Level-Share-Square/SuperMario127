extends Button

export var window_path : NodePath
onready var window_node = get_node(window_path)

export var text_edit_path : NodePath
onready var text_edit_node = get_node(text_edit_path)

onready var hover_sound = $HoverSound
onready var click_sound = $ClickSound

var last_hovered = false

func _pressed():
	click_sound.play()
	focus_mode = 0
	var level_data = LevelData.new()
	level_data.load_in(text_edit_node.text)
	CurrentLevelData.level_data = level_data
	music.loading = true
	yield(get_tree().create_timer(0.1), "timeout")
	var _reload = get_tree().reload_current_scene()

func update_text():
	music.loading = true
	yield(get_tree().create_timer(0.1), "timeout")
	text_edit_node.text = CurrentLevelData.level_data.get_encoded_level_data()
	yield(get_tree().create_timer(0.1), "timeout")
	music.loading = false
	
func _ready():
	var _connect = window_node.connect("window_opened", self, "update_text")
	yield(get_tree().create_timer(0.1), "timeout")
	music.loading = false

func _process(_delta):
	if is_hovered() and !last_hovered:
		hover_sound.play()
	last_hovered = is_hovered()
