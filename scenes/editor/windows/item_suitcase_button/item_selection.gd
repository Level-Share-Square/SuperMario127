extends ButtonSound


var placeable_item: Resource = preload("res://scenes/editor/items/placeable_items/placeable_objects/blue_coin.tres")
var button_pressed: bool
var hold_timer = 2

signal new_item_selected(placeable_item)

func _ready():
	set_item(placeable_item)
	connect("pressed", self, "button_pressed")
	connect("button_down", self, "button_held")
	connect("button_up", self, "button_released")

func check_held():
	if button_pressed == true:
		yield(get_tree().create_timer(hold_timer), "timeout")
		if button_pressed == true:
			#NOTHING WORKS BUT THIS I DONT KNOW WHY
			#YOU CAN TRY GET_NODE("%ITEMSUITCASE) IT WONT WORK
			#YOU CAN TRY $"../PATH TO SUITCASE" AND IT WONT WORK
			#I HATE THIS ENGINE
			get_parent().get_parent().get_parent().get_parent().new_favorite_selected(placeable_item, self)
			button_pressed = false
			return
		

func set_item(value: PlaceableItem):
	placeable_item = value
	
	hint_tooltip = placeable_item.item_name
	icon = placeable_item.icons[0]
	
	
func button_pressed():
	connect("new_item_selected", get_tree().get_current_scene(), "new_item_selected")
	emit_signal("new_item_selected", placeable_item)
	
func button_held():
	button_pressed = true
	check_held()
	
func button_released():
	button_pressed = false
