extends TextureRect

export var group := "all"
export var item_dragger_path : String 
export var placeable_items : NodePath
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
	
func _physics_process(_delta):
	if Input.is_action_pressed("ui_right") and visible and hovered:
		scroll_container.scroll_horizontal += 5
	if Input.is_action_pressed("ui_left") and visible and hovered:
		scroll_container.scroll_horizontal -= 5

func _ready():
	var _connect = close_button.connect("pressed", self, "pressed")
	var _connect2 = connect("mouse_entered", self, "mouse_entered")
	var _connect3 = connect("mouse_exited", self, "mouse_exited")
	
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
