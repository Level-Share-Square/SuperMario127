extends TextureRect

export var group := "SpecialGroup"
export var item_dragger_path : String 
export var placeable_items : NodePath
onready var grid_container_groups = $Groups/GridContainer
onready var scroll_container = $ScrollContainer
onready var grid_container = $ScrollContainer/GridContainer
onready var tween = $Tween
onready var close_button = $CloseButton
onready var close_button_rect = $CloseButton/TextureRect

onready var placeable_items_node = get_node(placeable_items)

var hovered = false
var last_layer

func _process(_delta):
	if close_button.is_hovered() and !close_button.pressed:
		close_button_rect.modulate = Color(0.8, 0.8, 0.8)
		
	else:
		close_button_rect.modulate = Color(1, 1, 1)

func open():
	if !visible:
		visible = true
		last_layer = Singleton.ModeSwitcher.layer
		Singleton.ModeSwitcher.layer = 99
		tween.interpolate_property(self, "rect_position",
			Vector2(773, 542), Vector2(773, 372), 0.25,
			Tween.TRANS_CIRC, Tween.EASE_OUT)
		tween.start()
		yield(tween, "tween_completed")
		Singleton.ModeSwitcher.button.visible = false
	
func close():
	Singleton.ModeSwitcher.button.visible = true
	tween.interpolate_property(self, "rect_position",
		Vector2(773, 372), Vector2(773, 542), 0.25,
		Tween.TRANS_CIRC, Tween.EASE_OUT)
	tween.start()
	yield(tween, "tween_completed")
	visible = false
	Singleton.ModeSwitcher.layer = last_layer
	
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

	# not a fan of this warning-ignore, but not not sure what a better name for it would be
	# warning-ignore: shadowed_variable  
	for group in placeable_items_node.get_children():
		if !(group is Group):
			continue #loose uncategorized items will be ignored
			
		var group_button = preload("res://scenes/editor/group_switcher.tscn").instance()
		group_button.group_picker = self
		group_button.switch_to_group = group
		grid_container_groups.add_child(group_button)
	change_group()

func change_group():
	for child in grid_container.get_children():
		child.queue_free() # haha i'm destroying a child isnt that funny
	
	var group_node = placeable_items_node.get_node(group)
	
	var columns_split = group_node.get_child_count()
	if columns_split % 2 > 0:
		columns_split += 1
	columns_split /= 2
	grid_container.columns = columns_split
	
	for item in group_node.get_children():
		
		var item_dragger_node = load(item_dragger_path).instance()
		item_dragger_node.item = item
		grid_container.add_child(item_dragger_node)
