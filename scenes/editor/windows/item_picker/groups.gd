extends HBoxContainer

onready var search = $"%Search"
onready var search_bar = $"%SearchBar"

var bar_shown = false

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in get_children():
		if "SearchBar" in str(i.name):
			i.visible = false
		else:
			i.visible = true
	search.connect("pressed", self, "_on_search_pressed")

func _on_search_pressed():
	bar_shown = !bar_shown
	if bar_shown:
		for i in get_children():
			i.visible = false
			search_bar.visible = true
			search.visible = true
	else:
		for i in get_children():
			if i == search_bar:
				i.visible = false
			else:
				i.visible = true
