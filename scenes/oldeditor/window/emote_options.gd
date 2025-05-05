extends HBoxContainer


const EXPRESSIONS_AMOUNT: int = 8
const ACTIONS_AMOUNT: int = 2
const PLAYER_AMOUNT: int = 8

const ICON_SCALE_FACTOR: float = 1.0

export var expression_textures: Texture
export var action_textures: Texture
export var player_textures: Texture

var expression_icons: Array
var action_icons: Array
var player_icons: Array

onready var expression_option = $"%ExpressionOption"
onready var action_option = $"%ActionOption"
onready var player_option = $"%PlayerOption"


# Called when the node enters the scene tree for the first time.
func _ready():
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
