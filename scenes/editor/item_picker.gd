extends TextureRect

export var group := "special"
export var item_dragger_path : String 
export var placeable_items : NodePath
onready var grid_container_groups = $Groups/GridContainer
onready var scroll_container = $ScrollContainer
onready var grid_container = $ScrollContainer/GridContainer
onready var tween = $Tween
onready var close_button = $CloseButton

var hovered = false
var last_layer

func open():
	if !visible:
		visible = true
		last_layer = mode_switcher.layer
		mode_switcher.layer = 99
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
	mode_switcher.layer = last_layer
	
func mouse_entered():
	hovered = true
	
func mouse_exited():
	hovered = false
	
func pressed():
	close()
		
func _ready():
	var _connect = close_button.connect("pressed", self, "pressed")
	var _connect2 = connect("mouse_entered", self, "mouse_entered")
	var _connect3 = connect("mouse_exited", self, "mouse_exited")
	
	for group_id in load("res://scenes/editor/groups/list.tres").ids:
		var group_resource = load("res://scenes/editor/groups/" + group_id + ".tres")
		var group_button = preload("res://scenes/editor/group_switcher.tscn").instance()
		group_button.group_picker = self
		group_button.switch_to_group = group_resource
		grid_container_groups.add_child(group_button)
	change_group()

func change_group():
	var group_resource = load("res://scenes/editor/groups/" + group + ".tres")
	
	for child in grid_container.get_children():
		child.queue_free() # haha i'm destroying a child isnt that funny
	
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
