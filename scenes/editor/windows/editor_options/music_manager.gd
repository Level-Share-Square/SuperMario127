extends VBoxContainer

onready var custom_music = $"%CustomMusic"
onready var preset_music = $"%PresetMusic"
onready var song_container = $"%SongContainer"
onready var song_type_label = $"%SongType"
onready var switch_button = $"%Switch"

const RESOURCE_PATH: String = "res://assets/music/resources/"
const SONG_PANEL: PackedScene = preload("res://scenes/editor/windows/editor_options/song_panel.tscn")

var song_in_use: SongPanel
var is_preset: bool

func get_resource_path(song_id: String) -> String:
	return RESOURCE_PATH + song_id + ".tres"
	
func _ready():
	var area_header: AreaHeader = CurrentLevelData.current_area.header
	var ids: PoolStringArray = Singleton.Music.level_songs.ids
	var sort_order: PoolStringArray = preload("res://assets/music/sort_order.tres").ids

	is_preset = !area_header.music is String

	for id in sort_order:
		var index = ids.find(id)
		var panel = SONG_PANEL.instance()
		song_container.add_child(panel)
		panel.populate_song(get_levelsong_from_id(id), index)
		
		if is_preset and area_header.music == index:
			panel.disable_button(true)
			song_in_use = panel
			
		panel.connect_use_button(self)

	set_preset(is_preset)
	switch_button.connect("pressed", self, "on_switch")
		
func set_preset(value: bool) -> void:
	if value:
		song_type_label.text = "Preset Music"
		switch_button.text = "Use Custom"
		custom_music.hide()
		preset_music.show()
	else:
		song_type_label.text = "Custom Music"
		switch_button.text = "Use Preset"
		custom_music.show()
		preset_music.hide()
	
func get_levelsong_from_id(id: String) -> Resource:
	return load(get_resource_path(id))

func on_switch():
	is_preset = !is_preset
	set_preset(is_preset)

func on_used(panel: SongPanel):
	CurrentLevelData.current_area.header.music = panel.id
	CurrentLevelData.area_headers[CurrentLevelData.area_id].music = panel.id

	if song_in_use:
		song_in_use.disable_button(false)
	panel.disable_button(true)
	song_in_use = panel
	
	
