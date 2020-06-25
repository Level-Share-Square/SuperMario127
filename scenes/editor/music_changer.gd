extends Control

onready var button_left = $Buttons/Left
onready var button_right = $Buttons/Right

onready var music_title = $MusicTitle
onready var music_note = $MusicNote

onready var hover_sound = $HoverSound
onready var click_sound = $ClickSound

onready var music_id_mapper = preload("res://assets/music/ids.tres")

func update_display():
	var data = CurrentLevelData.level_data
	var area = data.areas[CurrentLevelData.area]
	
	if typeof(area.settings.music) == TYPE_INT:
		var resource = MiscCache.music_nodes[area.settings.music]
		
		music_title.text = resource.title
		music_note.text = resource.note
	else:
		music_title.text = area.settings.music
		music_note.text = "Custom Music URL"
		
func text_entered(text):
	var re = RegEx.new()
	re.compile("(https:\\/\\/[^\\/]*)(.*)")

	if not re.search_all(text):
		music_note.text = "Invalid URL"
	else:
		CurrentLevelData.level_data.areas[CurrentLevelData.area].settings.music = text
		update_display()

func _ready():
	var _connect = button_left.connect("pressed", self, "button_press")
	var _connect2 = button_right.connect("pressed", self, "button_press")
	
	var _connect3 = button_left.connect("mouse_entered", self, "button_hovered")
	var _connect4 = button_right.connect("mouse_entered", self, "button_hovered")
	
	var _connect5 = music_title.connect("text_entered", self, "text_entered")
	update_display()
	
func button_hovered():
	hover_sound.play()
	
func button_press():
	var data = CurrentLevelData.level_data
	var area = data.areas[CurrentLevelData.area]
	
	area.settings.music = int(area.settings.music)
	
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
