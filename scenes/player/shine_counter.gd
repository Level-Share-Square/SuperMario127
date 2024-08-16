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
		var level_info = Singleton.CurrentLevelData.level_info

		# Only count shine sprites that have show_in_menu on
		var total_shine_count := 0
		var collected_shine_count := 0

		for shine_details in level_info.shine_details:
			total_shine_count += 1
			if level_info.collected_shines[str(shine_details["id"])]:
				collected_shine_count += 1

		label.text = "%s/%s" % [collected_shine_count, total_shine_count]

