extends TextureRect

export var group := "all"
export var item_dragger_path : String 
export var placeable_items : NodePath
onready var grid_container = $ScrollContainer/GridContainer
onready var tween = $Tween
onready var close_button = $CloseButton

func open():
	if !visible:
		visible = true
		tween.interpolate_property(self, "rect_position",
			Vector2(773, 542), Vector2(773, 372), 0.25,
			Tween.TRANS_CIRC, Tween.EASE_OUT)
		tween.start()
		yield(tween, "tween_completed")
	
func close():
	tween.interpolate_property(self, "rect_position",
		Vector2(773, 372), Vector2(773, 542), 0.25,
		Tween.TRANS_CIRC, Tween.EASE_OUT)
	tween.start()
	yield(tween, "tween_completed")
	visible = false
	
func pressed():
	close()

func _ready():
	var _connect = close_button.connect("pressed", self, "pressed")
	
	var group_resource = load("res://scenes/editor/groups/" + group + ".tres")
	
	var columns_split = group_resource.ids.size()
	if columns_split % 2 > 0:
		columns_split += 1
	columns_split /= 2
	grid_container.columns = columns_split
	
	for id in group_resource.ids:
		var item_dragger_node = load(item_dragger_path).instance()
		item_dragger_node.item = get_node(placeable_items).get_node(id)
		item_dragger_node.placeable_items_path = "../../../PlaceableItems"
		grid_container.add_child(item_dragger_node)
