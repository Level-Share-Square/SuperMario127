extends Control

onready var button_left = $Buttons/Left
onready var button_right = $Buttons/Right

onready var music_title = $MusicTitle
onready var music_note = $MusicNote

onready var hover_sound = $HoverSound
onready var click_sound = $ClickSound

onready var music_id_mapper = preload("res://assets/music/ids.tres")
onready var sorted_list = preload("res://assets/music/sort_order.tres")

func update_display():
	var data = Singleton.CurrentLevelData.level_data
	var area = data.areas[Singleton.CurrentLevelData.area]
	
	if typeof(area.settings.music) == TYPE_INT:
		var resource = Singleton.MiscCache.music_nodes[area.settings.music]
		
		music_title.text = resource.title
		music_note.text = resource.note
	else:
		music_title.text = area.settings.music
		music_note.text = "Custom Music URL"
		
func text_entered(text):
	var re = RegEx.new()
	re.compile("(https:\\/\\/[^\\/]*)(.*)")

	if not re.search_all(text) or !text.ends_with(".ogg"):
		music_note.text = "Invalid URL"
	else:
		Singleton.CurrentLevelData.level_data.areas[Singleton.CurrentLevelData.area].settings.music = text
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
	
func get_index_in_array(value, array):
	var index = 0
	for found_value in array:
		if value == found_value:
			return index
		index += 1
	return -1
	
func button_press():
	var data = Singleton.CurrentLevelData.level_data
	var area = data.areas[Singleton.CurrentLevelData.area]
	
	area.settings.music = area.settings.music if typeof(area.settings.music) == TYPE_INT else 0
	var music_name = music_id_mapper.ids[area.settings.music]
	var index = get_index_in_array(music_name, sorted_list.ids)
	
	if button_left.pressed:
		click_sound.play()
		index = wrapi(index - 1, 0, sorted_list.ids.size())
		area.settings.music = get_index_in_array(sorted_list.ids[index], music_id_mapper.ids)
		update_display()
		
	if button_right.pressed:
		click_sound.play()
		index = wrapi(index + 1, 0, sorted_list.ids.size())
		area.settings.music = get_index_in_array(sorted_list.ids[index], music_id_mapper.ids)
		update_display()
