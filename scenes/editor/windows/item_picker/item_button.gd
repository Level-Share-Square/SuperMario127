extends ButtonSound


export var placeable_item: Resource

onready var icon_display: TextureRect = $"%Icon"
onready var grid: TextureRect = $"%Grid"


func _ready():
	set_item(placeable_item)


func set_item(value: PlaceableItem):
	placeable_item = value
	
	if placeable_item.icons.size() > 1:
		icon_display.texture = create_cycling_icon(placeable_item.icons)
	else:
		icon_display.texture = placeable_item.icons[placeable_item.palette]
	
	hint_tooltip = placeable_item.item_name
	
	if placeable_item is PlaceableObject:
		grid.visible = false
	else:
		grid.visible = true


func create_cycling_icon(icons: Array) -> AnimatedTexture:
	var final_icon := AnimatedTexture.new()
	final_icon.fps = .75
	final_icon.frames = icons.size()
	
	for i in range(icons.size()):
		final_icon.set_frame_texture(i, icons[i])
	
	return final_icon
