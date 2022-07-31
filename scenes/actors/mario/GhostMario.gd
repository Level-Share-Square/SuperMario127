extends AnimatedSprite

onready var player = $"../Character"
onready var tween = $Tween
onready var tween2 = $Tween2
onready var file = File.new()
var ghost_pos
var ghost_anim
var ffc = -1
var sfc = 0
var play_ghost = false

func _ready():
	var level_info = Singleton.SavedLevels.get_current_levels()[Singleton.SavedLevels.selected_level]
	if file.file_exists("user://replays/" + str(level_info.level_name) + "_" + str(level_info.selected_shine) + "_pos.127ghost"):
		play_ghost = true

func _process(delta):
	var level_info = Singleton.SavedLevels.get_current_levels()[Singleton.SavedLevels.selected_level]
	if play_ghost:
		file.open("user://replays/" + str(level_info.level_name) + "_" + str(level_info.selected_shine) + "_pos.127ghost", File.READ)
		ghost_pos = file.get_var()
		file.close()
		file.open("user://replays/" + str(level_info.level_name) + "_" + str(level_info.selected_shine) + "_anim.127ghost", File.READ)
		ghost_anim = file.get_var()
		file.close()
		if ffc < ghost_pos.size() - 2:
			ffc += 1
		if sfc < ghost_pos.size() - 1:
			sfc += 1
		tween.interpolate_property(self, "position", ghost_pos[ffc], ghost_pos[sfc], delta)
		tween.start()
#this probably works???????
