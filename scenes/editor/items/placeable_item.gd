class_name PlaceableItem
extends Resource


export var item_name: String
export var icon: Texture
export var preview: Texture

export var change_to: String = self.name

export var items_in_sequence: int = 0
export var index_in_sequence: int = 0

export(Array, Texture) var palette_icons
export(Array, Texture) var palette_previews

export var placement_action: Script
export var removal_action: Script

var palette: int = 0


func set_palette(value: int):
	var palette_count: int = max(1, min(palette_icons.size(), palette_previews.size()))
	palette = clamp(value, 0, palette_count-1)
	
	icon = palette_icons[palette]
	preview = palette_previews[palette]
