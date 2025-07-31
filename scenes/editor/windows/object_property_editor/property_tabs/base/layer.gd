extends PropertyEditor

const LAYER_NAMES: Array = [
	"V. Back",
	"Back",
	"Middle",
	"Front"
]

func property_changed(key: String, new_value):
	if key != property[0]: return
	$OptionButton.selected = int(new_value)

func load_property(_editor: Editor, _objects: Dictionary, _property: Array):
	for layer_name in LAYER_NAMES:
		$OptionButton.add_item(layer_name)
	
	.load_property(_editor, _objects, _property)

func change_property(new_value):
	.change_property(int(new_value))
