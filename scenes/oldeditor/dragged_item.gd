extends Sprite

var editor : Node
var dragging = false

func _ready():
	editor = get_tree().get_current_scene()
	
func _process(_delta):
	var item = editor.dragging_item
	if item != null and !dragging:
		texture = item.preview
		dragging = true
	elif item == null and dragging:
		texture = null
		dragging = false
	
	if dragging:
		var mouse_pos = get_global_mouse_position()
		position = mouse_pos
