extends TextureButton

onready var mode_switcher = get_node("../../../ModeSwitcher")

func _pressed():
	mode_switcher.switch_to_testing()
