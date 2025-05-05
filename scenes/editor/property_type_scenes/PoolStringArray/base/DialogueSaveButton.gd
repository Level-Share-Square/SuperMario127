extends Button

var string
signal clicked

var dialogue: PoolStringArray
var dialogue_page: int = 0

var expression: int = 1
var action: int = 0
var player: int = 0

const EXPRESSIONS_AMOUNT: int = 8
const ACTIONS_AMOUNT: int = 2
const PLAYER_AMOUNT: int = 8

onready var back_button = $"%Back"
onready var next_button = $"%Next"
onready var index_display = $"%IndexDisplay"
onready var add_button = $"%Add"
onready var remove_button = $"%Remove"
onready var remote_tag = $"%RemoteTag"

onready var facing_dir = $"%FacingDir"
onready var expression_option = $"%ExpressionOption"
onready var action_option = $"%ActionOption"
onready var player_option = $"%PlayerOption"

onready var text_edit = $"%TextEdit"

export var expression_textures: Texture
export var action_textures: Texture
export var player_textures: Texture

# icons need to be scaled up... or theyll show up SUPER tiny in-game >w<;
const ICON_SCALE_FACTOR: int = 3
var expression_icons: Array
var action_icons: Array
var player_icons: Array

# just in case ur confused im using the editor ui to connect
# signals for most of these buttons



func _ready():
	var connect = connect("clicked", self, "_pressed")
	
	for i in range(0, EXPRESSIONS_AMOUNT):
		var new_image := AtlasTexture.new()
		new_image.set_atlas(expression_textures)
		new_image.region.size = Vector2(32, 32) * ICON_SCALE_FACTOR
		new_image.region.position.x = i * 32 * ICON_SCALE_FACTOR
		expression_icons.append(new_image)
		
		expression_option.add_icon_item(expression_icons[i], "", i)
	for i in range(0, ACTIONS_AMOUNT):
		var new_image := AtlasTexture.new()
		new_image.set_atlas(action_textures)
		new_image.region.size = Vector2(32, 32) * ICON_SCALE_FACTOR
		new_image.region.position.x = i * 32 * ICON_SCALE_FACTOR
		action_icons.append(new_image)
		
		action_option.add_icon_item(action_icons[i], "", i)
	for i in range(0, PLAYER_AMOUNT):
		var new_image := AtlasTexture.new()
		new_image.set_atlas(player_textures)
		new_image.region.size = Vector2(32, 32) * ICON_SCALE_FACTOR
		new_image.region.position.x = i * 32 * ICON_SCALE_FACTOR
		player_icons.append(new_image)
		
		player_option.add_icon_item(player_icons[i], "", i)
	
	yield(get_tree(), "idle_frame")
	dialogue = string.dialogue
	update()

func _pressed():
	save_page()
	
	string.dialogue = dialogue
	string.update_value()
	get_owner().close()

func save_page():
	dialogue[dialogue_page] = (
		str(expression).pad_zeros(2) + str(player) + str(action) 
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
	action = int(page_text.substr(3, 1))
	player = int(page_text.substr(2, 1))
	update_expression()
	update_action()
	update_player()

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
func set_expression(index : int):
	index = min(index, EXPRESSIONS_AMOUNT - 1)
	expression = index

#updates actions with their corresponding index
func update_action(): action_option.selected = action
func set_action(index : int):
	index = min(index, ACTIONS_AMOUNT - 1)
	action = index

#updates player expressions with their corresponding index
func update_player(): player_option.selected = player
func set_player(index : int):
	index = min(index, PLAYER_AMOUNT - 1)
	player = index
