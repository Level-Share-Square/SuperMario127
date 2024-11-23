extends EditorWindow

onready var next_button = $HBoxContainer/NextButton
onready var back_button = $HBoxContainer/BackButton
onready var page_title = $Title
onready var page_number = $HBoxContainer/NumberDisplay/PageNumber
onready var pages = $Pages

var page_nodes : Array
var current_page = 0

func _ready():
	for child in pages.get_children():
		if child is HelpPage:
			page_nodes.append(child)
	
	update_page()
	
	next_button.connect("pressed", self, "page_next")
	back_button.connect("pressed", self, "page_back")

func page_next():
	current_page += 1
	current_page = wrapi(current_page, 0, len(page_nodes))
	update_page()
	
	print("Current Page: " + str(current_page))

func page_back():
	current_page -= 1
	current_page = wrapi(current_page, 0, len(page_nodes))
	update_page()
	
	print("Current Page: " + str(current_page))

func update_page():
	var index : int = 0
	for page in page_nodes:
		if index == current_page:
			page.visible = true
			page_title.bbcode_text = "Help - " + "[color=yellow]" + page.page_name + "[/color]"
			page_number.text = str(index + 1) + "/" + str(len(page_nodes))
			print(page)
		else:
			page.visible = false
		
		index += 1
