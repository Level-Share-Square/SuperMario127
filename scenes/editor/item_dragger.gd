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
	icon.texture = load(item.icon.load_path)
	
func _process(_delta):
	grid.visible = true if !item.is_object else false
	if is_hovered() and !last_hovered:
		sound.play()
	last_hovered = is_hovered()

func _gui_input(event):
	var editor = get_tree().get_current_scene()
	if event is InputEventMouseButton:
		if event.pressed and item != null:
			var button_container = editor.placeable_items_button_container_node
			var boxes = button_container.get_children()
			var index_size = (button_container.number_of_boxes-1)
			for index in range(button_container.number_of_boxes):
				if index != index_size:
					var box = boxes[index_size - index]
					box.item = boxes[(index_size - index) - 1].item
					box.item_changed()
			boxes[0].item = item
			boxes[0].item_changed()
			editor.set_selected_box(editor.selected_box)
