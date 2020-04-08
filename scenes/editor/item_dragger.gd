extends TextureButton

onready var icon = $Icon
onready var tween = $Tween
onready var sound = $Sound
onready var click_sound = $ClickSound
var item : PlaceableItem
var placeable_items_path : String = ""

var last_hovered = false
var last_clicking = false

func _ready():
	icon.texture = item.icon
	
func _process(_delta):
	if is_hovered() and !last_hovered:
		sound.play()
	last_hovered = is_hovered()

func _gui_input(event):
	var editor = get_tree().get_current_scene()
	if event is InputEventMouseButton:
		if event.pressed and item != null:
			icon.texture = null
			editor.dragging_item = item
		else:
			icon.texture = item.icon
			yield(VisualServer, "frame_post_draw")
			editor.dragging_item = null
