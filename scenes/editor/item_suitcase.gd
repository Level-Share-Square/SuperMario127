extends VBoxContainer


onready var top_row = $Top/TopMat/TopItems
onready var bottom_row = $Bottom/BottomMat/Items
onready var item_base = $Bottom/BottomMat/Items/ItemBase

var buttons = []
var max_bottom = 15

onready var item_script = preload("res://scenes/editor/windows/item_suitcase_button/item_selection.gd")

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in max_bottom:
		var button = item_base.duplicate()
		bottom_row.add_child(button)
		button.visible = false
		button.set_script(item_script)
		buttons.append(button)
	item_base.queue_free()

func item_selected(placeable_item: Resource):
	bottom_row.move_child(bottom_row.get_children()[max_bottom - 1], 0)
	bottom_row.get_children()[0].set_item(placeable_item)
	bottom_row.get_children()[0].visible = true
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
