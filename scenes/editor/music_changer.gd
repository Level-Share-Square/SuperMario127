extends Control

export var shared_node_path : NodePath
onready var shared_node = get_node(shared_node_path)

onready var button_left = $Buttons/Left
onready var button_right = $Buttons/Right

onready var music_title = $MusicTitle
onready var music_note = $MusicNote

onready var hover_sound = $HoverSound
onready var click_sound = $ClickSound

onready var music_id_mapper = preload("res://assets/music/ids.tres")

func update_display():
	var data = CurrentLevelData.level_data
	var area = data.areas[0]
	
	var mapped_id = music_id_mapper.ids[area.settings.music]
	var resource = load("res://assets/music/resources/" + mapped_id + ".tres")
	
	music_title.text = resource.title
	music_note.text = resource.note

func _ready():
	button_left.connect("pressed", self, "button_press")
	button_right.connect("pressed", self, "button_press")
	
	button_left.connect("mouse_entered", self, "button_hovered")
	button_right.connect("mouse_entered", self, "button_hovered")
	update_display()
	
func button_hovered():
	hover_sound.play()
	
func button_press():
	var data = CurrentLevelData.level_data
	var area = data.areas[0]
	
	if button_left.pressed:
		click_sound.play()
		area.settings.music -= 1
		if area.settings.music < 0:
			area.settings.music = music_id_mapper.ids.size() - 1
		update_display()
		
	if button_right.pressed:
		click_sound.play()
		area.settings.music += 1
		if area.settings.music >= music_id_mapper.ids.size():
			area.settings.music = 0
		update_display()
