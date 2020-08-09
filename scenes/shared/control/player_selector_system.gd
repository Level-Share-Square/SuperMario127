extends Node

const selected_color : Color = Color("36a865")
const unselected_color : Color = Color("a83636")

var selected_style_box : StyleBoxFlat = StyleBoxFlat.new()
var unselected_style_box : StyleBoxFlat = StyleBoxFlat.new()

var selected_hover_stylebox : StyleBoxFlat = StyleBoxFlat.new()
var unselected_hover_stylebox : StyleBoxFlat = StyleBoxFlat.new()

var selectedButton : PlayerSelector

func _ready():
	# Prepare Styleboxes
	selected_style_box.set_bg_color(selected_color)
	unselected_style_box.set_bg_color(unselected_color)
	selected_hover_stylebox.set_bg_color(selected_color.lightened(0.5))
	unselected_hover_stylebox.set_bg_color(unselected_color.lightened(0.5))
	
	var style_boxes = [selected_style_box, unselected_style_box, selected_hover_stylebox, unselected_hover_stylebox]
	for style_box in style_boxes:
		style_box.set_corner_radius(CORNER_TOP_LEFT, 48)
		style_box.set_corner_radius(CORNER_TOP_RIGHT, 48)
		
	# Set them
	for i in range(0, get_child_count()):
		# Set player_id
		get_child(i).player_id = i
		if i == 0:
			var button : Button = get_child(0)
			_add_select_stylebox(button)
			selectedButton = button
		else:
			_add_unselect_stylebox(get_child(i))

func update_control_bindings():
	var controls_options = get_parent()
	for children in controls_options.get_children():
		if !children.get_name() in controls_options.ignore_children:
			var button : Button = children.get_node("KeyButton")
			button.text = ControlUtil.get_formatted_string(button.id, player_id())

func player_id() -> int:
	return selectedButton.player_id

func select(var button : Button):
	_add_select_stylebox(button)
	_add_unselect_stylebox(selectedButton)
			
	selectedButton = button

func _add_select_stylebox(var button : Button):
	_add_stylebox(button, selected_style_box, selected_hover_stylebox)

func _add_unselect_stylebox(var button : Button):
	_add_stylebox(button, unselected_style_box, unselected_hover_stylebox)
	
func _add_stylebox(var button : Button, var normal_stylebox, var hover_stylebox):
	button.add_stylebox_override("normal", normal_stylebox)
	button.add_stylebox_override("hover", hover_stylebox)
	button.add_stylebox_override("pressed", hover_stylebox)
