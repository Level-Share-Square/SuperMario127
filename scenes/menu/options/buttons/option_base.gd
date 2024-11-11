extends VBoxContainer
class_name OptionBase
tool

export var setting_section: String
export var setting_key: String

# no typing here so extended scripts
# can use their own types instead
var value = false
onready var label := $Label

## new functions
func reload_value(key: String, new_value = null):
	if Engine.is_editor_hint(): return
	if key != setting_key: return
	
	value = new_value
	if value == null:
		value = LocalSettings.load_setting(setting_section, setting_key, _get_default_value())
	_update_value()

func change_setting(new_value):
	if !Engine.is_editor_hint():
		LocalSettings.change_setting(setting_section, setting_key, new_value)


## built in functions
func _ready():
	value = _get_default_value()
	if !Engine.is_editor_hint():
		LocalSettings.connect("setting_changed", self, "reload_value")
		reload_value(setting_key)
	renamed()

func renamed():
	label.text = name.capitalize()


## override these
func _update_value():
	pass

func _get_default_value():
	return null
