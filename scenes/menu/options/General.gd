extends CenterContainer

onready var multiplayer_option: VBoxContainer = $VBoxContainer/GridContainer/Multiplayer

func _ready() -> void:
	if (is_instance_valid(Singleton.CurrentLevelData.level_info) and
	!Singleton.CurrentLevelData.level_info.validity_check.is_level_multiplayer_compatible):
		multiplayer_option.visible = false
