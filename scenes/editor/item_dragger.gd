extends TextureButton

onready var icon = $Icon
onready var tween = $Tween
onready var sound = $Sound
onready var click_sound = $ClickSound
onready var grid = $Grid
var item : PlaceableItem
var placeable_items_path : String = ""

var last_hovered = false
var last_clicking = false

func _ready():
	texture_normal = load(texture_normal.load_path)
	texture_hover = load(texture_hover.load_path)
	texture_pressed = load(texture_pressed.load_path)
	grid.texture = load(grid.texture.load_path)
	
	if item.palette_icons.size() == 0:
		icon.texture = load(item.icon.load_path)
	else:
		icon.texture = load(item.palette_icons[0].load_path)
	
func _process(_delta):
	grid.visible = true if !item.is_object else false
	if is_hovered() and !last_hovered:
		sound.play()
	last_hovered = is_hovered()

func button_pressed():
	var editor = get_tree().get_current_scene()
	if item != null:
		editor.update_button_container(item)
