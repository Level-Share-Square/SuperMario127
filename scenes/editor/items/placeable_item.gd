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

var icon: Texture = Texture.new()
var preview: Texture = Texture.new()
var palette: int = 0


func set_palette(value: int):
	var palette_count: int = max(1, min(icons.size(), previews.size()))
	palette = clamp(value, 0, palette_count-1)
	
	icon = icons[palette]
	preview = previews[palette]
