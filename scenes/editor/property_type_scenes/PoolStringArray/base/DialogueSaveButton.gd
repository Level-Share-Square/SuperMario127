extends Button

var string
signal clicked

var dialogue: PoolStringArray
var dialogue_page: int = 0

var expression: int = 1
var action: int = 0

const EXPRESSIONS_AMOUNT = 8
const ACTIONS_AMOUNT = 2

onready var back_button = $"../PageControls/Back"
onready var next_button = $"../PageControls/Next"
onready var index_display = $"../PageControls/IndexDisplay"
onready var add_button = $"../PageControls/Add"
onready var remove_button = $"../PageControls/Remove"
onready var remote_tag = $"../RemoteTag"
onready var facing_dir = $"../EmoteOptions/FacingDir"
onready var expression_option = $"../EmoteOptions/ExpressionOption"
onready var action_option = $"../EmoteOptions/ActionOption"
onready var expression_sprite = $"../EmoteOptions/Expression/Sprite"
onready var action_sprite = $"../EmoteOptions/Action/Sprite"
onready var text_edit = $"../TextEdit"

export var expression_textures : Texture
export var action_textures : Texture

var expression_icons : Array
var action_icons : Array

# just in case ur confused im using the editor ui to connect
# signals for most of these buttons

func _ready():
	var connect = connect("clicked", self, "_pressed")
	
	for i in range(0, EXPRESSIONS_AMOUNT):
		var new_image := AtlasTexture.new()
		new_image.set_atlas(expression_textures)
		new_image.region.size = Vector2(32, 32)
		new_image.region.position.x = i * 32
		expression_icons.append(new_image)
		
		expression_option.add_icon_item(expression_icons[i] , "", i)
	for i in range(0, ACTIONS_AMOUNT):
		var new_image := AtlasTexture.new()
		new_image.set_atlas(action_textures)
		new_image.region.size = Vector2(32, 32)
		new_image.region.position.x = i * 32
		action_icons.append(new_image)
		
		action_option.add_icon_item(action_icons[i] , "", i)
	
	yield(get_tree(), "idle_frame")
	dialogue = string.dialogue
	update()

func _pressed():
	save_page()
	
	string.dialogue = dialogue
	string.update_value()
	get_parent().get_parent().close()

func save_page():
	dialogue[dialogue_page] = (
		str(expression).pad_zeros(2) + str(action).pad_zeros(2) 
		+ remote_tag.text + ";"
		+ text_edit.text
	)

func _process(delta):
	index_display.text = "%s/%s" % [dialogue_page + 1, dialogue.size()]

func update(): change_page(0)
func change_page(direction: int):
	dialogue_page = clamp(dialogue_page + direction, 0, dialogue.size() - 1)
	
	back_button.disabled = (dialogue_page == 0)
	next_button.disabled = (dialogue_page >= dialogue.size() - 1)
	
	var page_text: String = dialogue[dialogue_page]
	var colon_offset: int = page_text.find(";")
	remote_tag.text = page_text.substr(4, colon_offset - 4)
	
	var display_text: String = page_text.substr(colon_offset + 1)
	text_edit.text = display_text
	
	# basicallyyy i'm storing these as two double digit numbers
	# at the start of each page, primitive but works fine :D
	expression = int(page_text.left(2))
	action = int(page_text.substr(2, 2))
	update_expression()
	update_action()

func remove_page():
	dialogue.remove(dialogue_page)
	update()
	
	remove_button.disabled = (dialogue.size() <= 1)

func add_page():
	dialogue.insert(dialogue_page + 1, "0100;")
	change_page(1)
	
	remove_button.disabled = (dialogue.size() <= 1)

#updates expressions with their corresponding index
func update_expression(): expression_option.selected = expression
func cycle_expression():
	expression = wrapi(expression + 1, 0, EXPRESSIONS_AMOUNT)
#	update_expression()
	
func set_expression(index : int):
	if index < EXPRESSIONS_AMOUNT-1:
		expression = index
	else:
		expression = 0
#	update_expression()

#updates actions with their corresponding index
func update_action(): action_option.selected = action
func cycle_action():
	action = wrapi(action + 1, 0, ACTIONS_AMOUNT)
#	update_action()

func set_action(index : int):
	if index < ACTIONS_AMOUNT-1:
		action = index
	else:
		action = 0
#	update_expression()
