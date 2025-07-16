extends HBoxContainer

onready var search = $"%Search"
onready var search_bar = $"%SearchBar"

var bar_shown = false

# Called when the node enters the scene tree for the first time.
func _ready():
	for child in get_children():
		if child == search_bar.get_parent():
			child.visible = false
		else:
			child.visible = true
	search.connect("pressed", self, "_on_search_pressed")

func _on_search_pressed():
	bar_shown = !bar_shown
	if bar_shown:
		for child in get_children():
			child.visible = false
			search_bar.get_parent().visible = true
			search.visible = true
	else:
		for child in get_children():
			if child == search_bar.get_parent():
				search_bar.get_parent().visible = false
			else:
				child.visible = true
