extends Label


func _ready():
	text = "v%s" % [ProjectSettings.get_setting("global/Game Version")]
