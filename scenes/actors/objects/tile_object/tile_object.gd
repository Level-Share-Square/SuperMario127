extends GameObject

onready var tile_map = $"%TileMap"

var tile_data := TileData.new()
var tint := Color.white
var editor_border_color := Color(0.2, 0.2, 0.8, 0.5)

func load_placeable_item():
	placeable_item = PlaceableItem.new()
	placeable_item.item_name = "Tile Stamp"
	placeable_item.icons.append(load("res://assets/icons/settings.svg"))

func _ready():
	set_tiles()
	connect("property_changed", self, "property_changed")
		
func _register_properties():
	register_property(4, "tile_data", tile_data, false)
	register_property(5, "tint", tint, true)

func _draw() -> void:
	draw_rect(editor_rect.grow(1), editor_border_color, false, 2)

func set_tiles():
	for pos in tile_data.used_tiles:
		print(pos)
		var tile = tile_data.get_tile_data_from_packed(tile_data.get_packed_tile_at(pos))
		if is_air(tile):
			continue
		tile_map.set_cellv(pos, tile_util.get_real_tile_set_id(tile[0], tile[1], tile[2]))
		print(tile_map.get_cellv(pos))
	tile_map.update_bitmask_region()
	tile_map.update_dirty_quadrants()
	var used_rect: Rect2 = tile_map.get_used_rect()

	editor_rect = Rect2(Vector2.ZERO, used_rect.size*32)
	tile_map.modulate = tint
	

func is_air(tile_data: Array):
	return tile_data[0] <= 0 or tile_data[1] < 0 or tile_data[2] < 0

func property_changed(key, value):
	print(key, value)
	if key == "tint":
		tile_map.modulate = value
