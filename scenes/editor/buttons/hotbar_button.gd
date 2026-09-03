extends ButtonSound

const FAVORITE_COLOR: Color = Color(0.5, 1, 1)
const WAIT_TIMER: float = 1.0

onready var tween = $Tween
onready var tween_hover = $TweenHover
onready var tween_progress = $TweenProgress

onready var icon_offset = $"%IconOffset"
onready var icon_node = $"%Icon"
onready var progress = $"%Progress"
onready var series_container = $"%SeriesContainer"

onready var hotbar = $"%Hotbar"

var item: PlaceableItem
var favorite = false
var palette = 0
var variant: int = 0

var timer: float = 0.0
var timer_start: bool = false

func set_favorite(is_favorite: bool):
	favorite = is_favorite
	self_modulate = Color.white if not favorite else FAVORITE_COLOR

func change_item(new_item: PlaceableItem):
	tween_progress.disconnect("tween_all_completed", hotbar, "new_favorite_selected")
	item = new_item
	if is_instance_valid(item):
		if palette < item.icons.size():
			icon_node.texture = item.icons[palette]
		else:
			icon_node.texture = item.icons[0]
		tween_progress.connect("tween_all_completed", hotbar, "new_favorite_selected", [item, get_index()])
		for indicator in series_container.get_children():
			variant = item.index_in_sequence
			indicator.color = Color(0, 0.75, 0.75) if indicator.get_index() == variant else Color("bfbfbf")
			if indicator.get_index() < item.items_in_sequence:
				indicator.show()
			else:
				indicator.hide()

func _physics_process(delta):
	if timer_start == true:
		timer += delta

func button_down():
#	print(variant)
	tween.stop_all()
	tween.interpolate_property(icon_node, "rect_position:y",
		icon_node.rect_position.y, -3, 0.075,
		Tween.TRANS_CIRC, Tween.EASE_OUT)
	tween.start()
	
	var default_color: Color = Color.white if not favorite else FAVORITE_COLOR
	var target_color: Color = FAVORITE_COLOR if not favorite else Color.white
	
	tween_progress.interpolate_property(self, "self_modulate",
		self_modulate, target_color, WAIT_TIMER,
		Tween.TRANS_CIRC, Tween.EASE_IN_OUT)
	tween_progress.start()

func button_up():
	tween.stop_all()
	tween.interpolate_property(icon_node, "rect_position:y",
		icon_node.rect_position.y, 1, 0.15,
		Tween.TRANS_BOUNCE, Tween.EASE_IN)
	tween.start()
	if timer <= 0.5 and timer != 0.0:
		change_variant()
	else:
		pass
	timer = 0.0
	timer_start = false
	
	tween_progress.stop_all()
	set_favorite(favorite)

func change_variant():
	if item.change_to != "":
		var old_item = item
		var new_item = hotbar.placeable_items.placeable_items[item.change_to]
		change_item(new_item)
		var index = get_index()
		hotbar.loadouts[hotbar.selected_loadout].pop_at(index)
		hotbar.loadouts[hotbar.selected_loadout].insert(index, hotbar.placeable_items.placeable_items.find_key(new_item))
#		print(hotbar.loadouts[hotbar.selected_loadout])
		hotbar._on_item_button_pressed(self)

func mouse_entered():
	tween_hover.stop_all()
	tween_hover.interpolate_property(icon_offset, "rect_position:y",
		icon_offset.rect_position.y, -1, 0.075,
		Tween.TRANS_CIRC, Tween.EASE_OUT)
	tween_hover.start()

func mouse_exited():
	tween_hover.stop_all()
	tween_hover.interpolate_property(icon_offset, "rect_position:y",
		icon_offset.rect_position.y, 0, 0.075,
		Tween.TRANS_CIRC, Tween.EASE_OUT)
	tween_hover.start()


func gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_RIGHT and event.pressed:
			hotbar.palette_selected(wrapi(palette + 1, 0, item.icons.size() - 1), self)
			play_bounce_anim()
		if event.button_index == BUTTON_MIDDLE and event.pressed:
			hotbar.new_favorite_selected(item, get_index())
			play_bounce_anim()

func play_bounce_anim():
	tween.stop_all()
	tween.interpolate_property(icon_node, "rect_position:y",
		icon_node.rect_position.y, -3, 0.075,
		Tween.TRANS_CIRC, Tween.EASE_OUT)
	tween.start()
	yield(tween, "tween_completed")
	tween.stop_all()
	tween.interpolate_property(icon_node, "rect_position:y",
		icon_node.rect_position.y, 1, 0.15,
		Tween.TRANS_BOUNCE, Tween.EASE_IN)
	tween.start()
