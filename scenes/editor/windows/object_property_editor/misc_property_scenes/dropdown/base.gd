extends PropertyEditor

onready var option_button = $"%OptionButton"
onready var line_edit = $"%LineEdit"

var lookup_table: Dictionary
var add_option: bool = false

var dropdown_args: Array

func property_changed(key: String, new_value):
	if key != property[0]: return

	reload_lookup_table()
	option_button.select(lookup_table.keys().find(new_value))
	
func load_property(_editor: Editor, init_value, _property: Array, property_name = null):
	editor = _editor
	property = _property
	var property_id: String = property[0]
	dropdown_args = property[1]
	
	get_node("%PropertyName").text = NAME_TEXT % property_id.capitalize() if !property_name else NAME_TEXT % property_name
	if dropdown_args.size() == 3:
		add_option = true

	if property.size() > 2:
		var property_info = property[2]
		if property_info is PropertyInfo:
			hint_tooltip = property_info.hint
	
	if not ready:
		yield(self, "ready")
	reload_lookup_table()
	
	property_changed(property_id, init_value)


func item_selected(index: int):
	if option_button.get_item_text(index) == "Add":
		option_button.hide()
		line_edit.show()
		return
	
	change_property(lookup_table.find_key(option_button.get_item_text(index)))

func reload_lookup_table():
	lookup_table = dropdown_args[0].call(dropdown_args[1])
	
	option_button.clear()
	for value in lookup_table.values():
		option_button.add_item(value)
		
	if add_option:
		option_button.add_item("Add")


func text_entered(new_text):
	lookup_table.get_or_add(new_text, new_text)
	
	var new_element_args: Array = dropdown_args[2]
	new_element_args[0][new_element_args[1]].append(new_text)
	
	reload_lookup_table()
	line_edit.hide()
	option_button.show()
	
	option_button.select(lookup_table.size() - 1)
	option_button.emit_signal("item_selected", lookup_table.size() - 1)
