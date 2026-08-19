extends PropertyEditor


const EXPAND_NONE: String = "> All"
const EXPAND_SOME: String = "> Some"

onready var options = $"%Options"
onready var expand_button = $"%ExpandButton"

var lookup_table: Dictionary
var stored_property: PoolStringArray
var dropdown_args: Array

func property_changed(key: String, new_value):
	if key != property[0]: return
	expand_button.text = EXPAND_NONE if new_value.empty() else EXPAND_SOME
	if expand_button.toggled:
		expand_button.text = expand_button.text.replace(">", "V")
	stored_property = new_value
	reload_lookup_table()

func load_property(_editor: Editor, init_value, _property: Array, property_name = null):
	editor = _editor
	property = _property
	
	var property_id: String = property[0]
	dropdown_args = property[1]
	
	get_node("%PropertyName").text = NAME_TEXT % property_id.capitalize() if !property_name else NAME_TEXT % property_name

	if property.size() > 2:
		var property_info = property[2]
		if property_info is PropertyInfo:
			hint_tooltip = property_info.hint
	stored_property = init_value
	
	reload_lookup_table()
	property_changed(property_id, init_value)

func item_selected(is_toggled: bool, layer_uuid: String):
	var new_property: PoolStringArray = stored_property
	if is_toggled and not layer_uuid in new_property:
		new_property.append(layer_uuid)
	elif not is_toggled and layer_uuid in new_property:
		new_property.remove(new_property.find(layer_uuid))
	change_property(new_property)

func reload_lookup_table():
	# child murder !! yippee
	for child in options.get_children():
		child.queue_free()
	lookup_table = dropdown_args[0].call(dropdown_args[1])
	for mission_uuid in lookup_table.keys():
		var mission_name: String = lookup_table[mission_uuid]
		var check_button := CheckButton.new()
		check_button.text = "%s:" % mission_name
		check_button.icon_align = Button.ALIGN_RIGHT
		check_button.enabled_focus_mode = Control.FOCUS_NONE
		check_button.theme_type_variation = "CheckButtonTransparent"
		check_button.pressed = mission_uuid in stored_property
		check_button.connect("toggled", self, "item_selected", [mission_uuid])
		options.add_child(check_button)
