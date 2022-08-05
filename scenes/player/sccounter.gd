extends Control

onready var label = $Label
onready var label_shadow = $LabelShadow
onready var tween = $Tween

var last_coin_amount := 0

export var collected_height : float
var normal_height : float

var time_until_fall = 0.0

func _physics_process(delta):
	populate_info_panel()
	label_shadow.text = label.text


func populate_info_panel() -> void:
		var level_info = Singleton.SavedLevels.get_current_levels()[Singleton.SavedLevels.selected_level]

		var collected_star_coin_count = level_info.collected_star_coins.values().count(true)
		label.text = "%s/%s" % [collected_star_coin_count, level_info.collected_star_coins.size()]
