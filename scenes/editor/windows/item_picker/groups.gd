extends HBoxContainer

onready var search = $"%Search"
onready var search_bar = $"%SearchBar"

onready var special = $"%Special"
onready var dialogue = $"%Dialogue"
onready var switches = $"%Switches"
onready var warp = $"%Warp"
var button_colors: Dictionary = {
	"special": Color("8e27a8"),
	"dialogue": Color("805300"),
	"switches": Color("1937fa"),
	"warp": Color("1eaf00"),
}

var current_category = ""

var bar_shown = false

# Called when the node enters the scene tree for the first time.
func _ready():
	for child in get_children():
		if child == search_bar.get_parent():
			child.visible = false
		else:
			child.visible = true
	search.connect("pressed", self, "_on_search_pressed")
	special.connect("pressed", self, "_on_special_pressed")
	dialogue.connect("pressed", self, "_on_dialogue_pressed")
	switches.connect("pressed", self, "_on_switches_pressed")
	warp.connect("pressed", self, "_on_warp_pressed")

func _on_search_pressed():
	var item_box = owner.items_box
	item_box.search_bar.text = ""
	item_box.load_items(item_box.get_items_by_group(""), true)
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
				
func switch_category(category: String):
	var item_box = owner.items_box
	var buttons = [special, dialogue, switches, warp]
	for i in buttons:
		var button_name = i.name.to_lower()
		if button_name == category:
			if button_name == current_category:
				i.color = button_colors[button_name]
				item_box.load_items(item_box.get_items_by_group(""), true)
				current_category = ""
			else:
				i.color = Color("000000")
				item_box.load_items(item_box.get_items_by_group(category), true)
				current_category = category
		else:
			i.color = button_colors[button_name]
		i.set_color()
		
func reset():
	var buttons = [special, dialogue, switches, warp]
	for i in buttons:
		var button_name = i.name.to_lower()
		i.color = button_colors[button_name]
		i.set_color()
	current_category = ""

func _on_special_pressed():
	switch_category("special")
	
func _on_dialogue_pressed():
	switch_category("dialogue")

func _on_switches_pressed():
	switch_category("switches")

func _on_warp_pressed():
	switch_category("warp")
