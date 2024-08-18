extends HBoxContainer

export var remapper_path: NodePath
onready var remapper = get_node(remapper_path)

export var buttons_by_screen: Dictionary
export var category_init: Array

var loading_defaults: bool = true

# initialize controls
func _ready():
	for array in category_init:
		# will load preset if category doesn't
		# exist in the config file yet
		if not LocalSettings.config.has_section(array[0]):
			print(array[0] + " doesn't exist, loading preset")
			load_preset(array[1], array[0])
	
	loading_defaults = false

func load_preset(preset_path: String, category: String = ""):
	var config = ConfigFile.new()
	
	var err = config.load(preset_path)
	if err != OK:
		push_error("Error loading config file!")
		return
	
	if category == "":
		category = remapper.current_category.get_child(0).input_group
	
	for key in config.get_section_keys("Preset"):
		LocalSettings.change_setting(category, key, config.get_value("Preset", key, []))
	
	# we load defaults on ready, which is before
	# remapper loads; and this line causes errors then
	# so in that situation we let it load on its own
	if not loading_defaults:
		remapper.load_all_bindings()

func update_visible_buttons(category: String):
	for child in get_children():
		if child is Button:
			child.visible = (get_path_to(child) in buttons_by_screen[category])
