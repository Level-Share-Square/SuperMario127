extends TileMap

var level_size = Vector2(0 ,0)
onready var level_size_node = get_node("../LevelSettings")
onready var global_vars_node = get_node("../GlobalVars")
onready var ghost_tile = get_node("../GhostTile")
onready var global_vars = get_node("../GlobalVars")
onready var air_tile = global_vars.get_tile(0, 0)

func _ready():
	var level_size_temp = level_size_node.level_size
	level_size = level_size_temp
	pass

func _physics_process(delta):
	if global_vars_node.game_mode == "Editing":
		var mouse_pos = get_global_mouse_position()
		var mouse_screen_pos = get_viewport().get_mouse_position()
		var mouse_tile_pos = Vector2(floor(mouse_pos.x / 32), floor(mouse_pos.y / 32))
		var mouse_grid_pos = Vector2((mouse_tile_pos.x * 32) + 16, (mouse_tile_pos.y * 32) + 16)
		
		ghost_tile.modulate = Color(1, 1, 1, 0.5)
		ghost_tile.position = Vector2(mouse_tile_pos.x * 32, mouse_tile_pos.y * 32)
		
		if global_vars.is_tile:
			var level_tilesets : LevelTilesets = load("res://assets/level_tilesets.tres")
			var tileset_info = load("res://assets/tilesets/" + level_tilesets.tilesets[global_vars.selected_tileset_id] + ".tres")
			ghost_tile.texture = tileset_info.placing_texture
			ghost_tile.region_rect = tileset_info.placing_rect
		
		var tile = global_vars.get_tile(global_vars.selected_tileset_id, global_vars.selected_tile_id)
		if mouse_screen_pos.y > 70:
			if Input.is_mouse_button_pressed(1):
				if mouse_tile_pos.x > -1 and mouse_tile_pos.x < level_size.x:
					if mouse_tile_pos.y > -1 and mouse_tile_pos.y < level_size.y:
						if global_vars.is_tile:
							if (get_cell(mouse_tile_pos.x, mouse_tile_pos.y) != tile):
								set_cell(mouse_tile_pos.x, mouse_tile_pos.y, tile)
								global_vars.editor.set_tile(mouse_tile_pos, global_vars.selected_tileset_id, global_vars.selected_tile_id)
								self.update_bitmask_area(Vector2(mouse_tile_pos.x, mouse_tile_pos.y))
						elif global_vars.placement_mode == "Tile":
							global_vars.editor.create_object(self, global_vars_node.selected_object_type, { "position": mouse_grid_pos, "scale": Vector2(1, 1), "rotation_degrees": 0 })
			elif Input.is_mouse_button_pressed(2):
				if mouse_tile_pos.x > -1 and mouse_tile_pos.x < level_size.x:
					if mouse_tile_pos.y > -1 and mouse_tile_pos.y < level_size.y:
						if global_vars.is_tile:
							set_cell(mouse_tile_pos.x, mouse_tile_pos.y, air_tile)
							global_vars.editor.set_tile(mouse_tile_pos, 0, 0)
							self.update_bitmask_area(Vector2(mouse_tile_pos.x, mouse_tile_pos.y))
						else:
							global_vars.editor.delete_object_at_position(self, mouse_grid_pos)
			if Input.is_action_just_pressed("click"):
				pass
				
