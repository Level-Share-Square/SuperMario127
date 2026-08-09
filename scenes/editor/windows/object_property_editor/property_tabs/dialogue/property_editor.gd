extends PropertyEditor

onready var remove_button: Button = $"%Remove"
onready var add_button: Button = $"%Add"
onready var back_button: Button = $"%Back"
onready var next_button: Button = $"%Next"
onready var index_display: Label = $"%IndexDisplay"
onready var remote_tag: LineEdit = $"%RemoteTag"
onready var big_text: BigText = $"%BigText"
onready var expression_option: OptionButton = $"%ExpressionOption"
onready var action_option: OptionButton = $"%ActionOption"
onready var player_option: OptionButton = $"%PlayerOption"

const EXPRESSIONS_AMOUNT: int = 8
const ACTIONS_AMOUNT: int = 2
const PLAYER_AMOUNT: int = 8

var stored_dialogue: PoolStringArray
var dialogue_page: int = 0
var expression: int = 1
var action: int = 0
var player: int = 0


func _ready():
	change_page(0)

func property_changed(key: String, new_value: PoolStringArray) -> void:
	if key != property[0]: return
	load_dialogue(new_value)

func load_dialogue(new_dialogue: PoolStringArray) -> void:
	stored_dialogue = new_dialogue
	if is_instance_valid(remove_button):
		change_page(0)

func save_page(_unused = ""):
	stored_dialogue[dialogue_page] = (
		str(expression).pad_zeros(2) + str(player) + str(action) 
		+ remote_tag.text + ";"
		+ big_text.text
	)
	change_property(stored_dialogue)

func change_page(direction: int):
	dialogue_page = clamp(dialogue_page + direction, 0, stored_dialogue.size() - 1)
	
	back_button.disabled = (dialogue_page == 0)
	next_button.disabled = (dialogue_page >= stored_dialogue.size() - 1)
	
	var page_text: String = stored_dialogue[dialogue_page]
	var colon_offset: int = page_text.find(";")
	
	remote_tag.text = page_text.substr(4, colon_offset - 4)
	
	var display_text: String = page_text.substr(colon_offset + 1)
	big_text.text = display_text
	
	index_display.text = "%s/%s" % [dialogue_page + 1, stored_dialogue.size()]
	
	# basicallyyy i'm storing these as two double digit numbers
	# at the start of each page, primitive but works fine :D
	expression = int(page_text.left(2))
	action = int(page_text.substr(3, 1))
	player = int(page_text.substr(2, 1))
	update_expression()
	update_action()
	update_player()

func remove_page():
	stored_dialogue.remove(dialogue_page)
	change_page(0)
	
	remove_button.disabled = (stored_dialogue.size() <= 1)

func add_page():
	stored_dialogue.insert(dialogue_page + 1, "0100;")
	change_page(1)
	
	remove_button.disabled = (stored_dialogue.size() <= 1)

## updates expressions with their corresponding index
func update_expression(): expression_option.selected = expression
func set_expression(index: int):
	index = min(index, EXPRESSIONS_AMOUNT - 1)
	expression = index
	save_page()

## updates actions with their corresponding index
func update_action(): action_option.selected = action
func set_action(index: int):
	index = min(index, ACTIONS_AMOUNT - 1)
	action = index
	save_page()

## updates player expressions with their corresponding index
func update_player(): player_option.selected = player
func set_player(index: int):
	index = min(index, PLAYER_AMOUNT - 1)
	player = index
	save_page()
