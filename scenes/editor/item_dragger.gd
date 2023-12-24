extends TextureButton

onready var icon = $Icon
onready var tween = $Tween
onready var sound = $Sound
onready var click_sound = $ClickSound
onready var grid = $Grid

var editor
var item : PlaceableItem
var placeable_items_path : String = ""

var last_hovered = false
var last_clicking = false

func _ready():
	editor = get_tree().get_current_scene()
	texture_normal = load(texture_normal.load_path)
	texture_hover = load(texture_hover.load_path)
	texture_pressed = load(texture_pressed.load_path)
	grid.texture = load(grid.texture.load_path)
	
	if item.palette_icons.size() == 0:
		icon.texture = load(item.icon.load_path)
	else:
		icon.texture = load(item.palette_icons[0].load_path)
	
func _process(_delta):
	var hovered = is_hovered()
	grid.visible = true if !item.is_object else false
	if hovered and Input.is_action_just_pressed("pin_item"):
		editor.pin_item(item)
	if hovered and !last_hovered:
		sound.play()
	last_hovered = hovered

func button_pressed():
	if item != null:
		editor.update_button_container(item)
