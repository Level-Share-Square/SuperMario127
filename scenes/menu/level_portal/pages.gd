extends HBoxContainer


onready var http_request = $"%HTTPRequest"
onready var go_to_page = $GoToPage
onready var padding = $Padding


const PAGE_BUTTON := preload("res://scenes/menu/level_portal/page_button.tscn")
const BUTTON_AMOUNT: int = 10


func connect_page_button(button: Button, target_page: int):
	button.connect("pressed", http_request, "load_page", [target_page])


func clear_buttons():
	for child in get_children():
		if child is Button:
			child.call_deferred("queue_free")


func load_page_buttons(page: int, total_pages: int):
	clear_buttons()
	
	var total_buttons: int = min(BUTTON_AMOUNT, total_pages)
	go_to_page.visible = (total_buttons == BUTTON_AMOUNT)
	padding.visible = go_to_page.visible
	
	var add_amount: int = (page - total_buttons/2)
	add_amount = clamp(add_amount, 0, total_pages - total_buttons)
	
	var start_button: Button = PAGE_BUTTON.instance()
	start_button.text = "<"
	start_button.disabled = (page <= 1)
	connect_page_button(start_button, page - 1)
	call_deferred("add_child", start_button)
	call_deferred("move_child", start_button, 0)
	
	for i in range(total_buttons):
		var button: Button = PAGE_BUTTON.instance()
		var button_page: int = (i + 1) + add_amount
		
		if i == 0:
			button.text = str(1)
			button.disabled = (page <= 1)
			connect_page_button(button, 1)
		elif i == BUTTON_AMOUNT - 1:
			button.text = str(total_pages)
			button.disabled = (page == total_pages)
			connect_page_button(button, total_pages)
		else:
			button.text = str(button_page)
			button.disabled = (page == button_page)
			connect_page_button(button, button_page)
		
		call_deferred("add_child", button)
		call_deferred("move_child", button, i + 1)

	var end_button: Button = PAGE_BUTTON.instance()
	end_button.text = ">"
	end_button.disabled = (page >= total_pages)
	connect_page_button(end_button, page + 1)
	call_deferred("add_child", end_button)
	call_deferred("move_child", end_button, total_buttons + 2)
