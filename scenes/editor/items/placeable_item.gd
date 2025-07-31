class_name PlaceableItem
extends Resource


export var item_name: String

export var groups := PoolStringArray()

export var change_to: String = self.item_name

export var items_in_sequence: int = 0
export var index_in_sequence: int = 0

export(Array, Texture) var icons
export(Array, Texture) var previews

export var placement_action: Script
export var removal_action: Script

export var priority: int = 0

var icon: Texture = Texture.new()
var preview: Texture = Texture.new()
var palette: int = 0


func get_palette_count() -> int:
	return int(max(1, min(icons.size(), previews.size()))) - 1

func set_palette(value: int):
	var palette_count: int = get_palette_count()
	palette = clamp(value, 0, palette_count)
	
	icon = icons[palette]
	preview = previews[palette]
