extends EditorWindow

onready var next_button = $HBoxContainer/NextButton
onready var back_button = $HBoxContainer/BackButton
onready var page_selector = $HBoxContainer/PageSelect
onready var page_title = $Title
onready var page_number = $HBoxContainer/NumberDisplay/PageNumber
onready var pages = $Pages

var page_nodes : Array
var current_page = 0

func _ready():
	page_nodes = pages.get_children()
	
	for page_index in range(len(page_nodes)):
		page_selector.add_item(page_nodes[page_index].page_name, page_index)
	
	update_page()
	
	next_button.connect("pressed", self, "page_next")
	back_button.connect("pressed", self, "page_back")
	page_selector.connect("item_selected", self, "page_set")

func page_next():
	current_page += 1
	current_page = wrapi(current_page, 0, len(page_nodes))
	update_page()
	
	#print("Current Page: " + str(current_page))

func page_back():
	current_page -= 1
	current_page = wrapi(current_page, 0, len(page_nodes))
	update_page()
	
	#print("Current Page: " + str(current_page))

func page_set(page_id):
	current_page = page_id
	current_page = wrapi(current_page, 0, len(page_nodes))
	update_page()
	
	#print("Current Page: " + str(current_page))

func update_page():
	var index : int = 0
	for page in page_nodes:
		if index == current_page:
			page.visible = true
			page_title.bbcode_text = "Help - " + "[color=yellow]" + page.page_name + "[/color]"
			page_number.text = str(index + 1) + "/" + str(len(page_nodes))
			page_selector.selected = current_page
			#print(page)
		else:
			page.visible = false
		
		index += 1
