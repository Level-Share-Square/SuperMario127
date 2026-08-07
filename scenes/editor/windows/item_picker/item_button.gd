extends ButtonSound


var placeable_item: Resource = preload("res://scenes/editor/items/placeable_items/placeable_objects/blue_coin.tres")

onready var icon_display: TextureRect = $"%Icon"
signal item_selected(placeable_item)


func _ready():
	set_item(placeable_item)


func set_item(value: PlaceableItem):
	placeable_item = value
	
	set_texture(CurrentLevelData.editor_data.show_palettes)
	
	hint_tooltip = placeable_item.item_name

func set_texture(show_palettes: bool = true):
	if placeable_item.icons.size() > 1 and show_palettes:
		icon_display.texture = create_cycling_icon(placeable_item.icons)
	else:
		icon_display.texture = placeable_item.icons[placeable_item.palette]

func create_cycling_icon(icons: Array) -> AnimatedTexture:
	var final_icon := AnimatedTexture.new()
	final_icon.fps = .75
	final_icon.frames = icons.size()
	
	for i in range(icons.size()):
		final_icon.set_frame_texture(i, icons[i])
	
	return final_icon
