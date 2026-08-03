extends PropertyEditor

var lookup_table: Dictionary

func property_changed(key: String, new_value):
	if key != property[0]: return

	$OptionButton.select(lookup_table.keys().find(new_value))
	reload_lookup_table()
	
func load_property(_editor: Editor, init_value, _property: Array, property_name = null):
	editor = _editor
	property = _property
	var property_id: String = property[0]
	
	get_node("%PropertyName").text = NAME_TEXT % property_id.capitalize() if !property_name else NAME_TEXT % property_name

	reload_lookup_table()
	
	property_changed(property_id, init_value)


func item_selected(index: int):
	change_property(lookup_table.find_key($OptionButton.get_item_text(index)))

func reload_lookup_table():
	lookup_table = property[1][0].call(property[1][1])
	
	$OptionButton.clear()
	for value in lookup_table.values():
		$OptionButton.add_item(value)
