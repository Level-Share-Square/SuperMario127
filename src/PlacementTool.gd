extends TileMap

var level_size = Vector2(0 ,0)
onready var level_size_node = get_node("../LevelSettings")
onready var global_vars_node = get_node("../GlobalVars")
onready var ghost_tile = get_node("../GhostTile")
onready var global_vars = get_node("../GlobalVars")
onready var level_objects = get_node("../LevelObjects")
onready var air_tile = global_vars.get_tile(0, 0)
var ghost_object
var layer = 1

func switch_layers():
	layer += 1
	if layer > 2:
		layer = 0

func _ready():
	var level_size_temp = level_size_node.level_size
	level_size = level_size_temp
	pass

func _physics_process(delta):
	if global_vars_node.game_mode == "Editing":
		if Input.is_action_just_pressed("switch_layers"):
			switch_layers()
		var mouse_pos = get_global_mouse_position()
		var mouse_screen_pos = get_viewport().get_mouse_position()
		var mouse_tile_pos = Vector2(floor(mouse_pos.x / 32), floor(mouse_pos.y / 32))
		var mouse_grid_pos = Vector2((mouse_tile_pos.x * 32) + 16, (mouse_tile_pos.y * 32) + 16)
		var tilemap_node = self
		ghost_tile.z_index = 1
		if layer == 0:
			tilemap_node = get_node("../BackgroundTileMap")
			ghost_tile.z_index = -11
		elif layer == 2:
			tilemap_node = get_node("../VeryForegroundTileMap")
			ghost_tile.z_index = 9
		
		if global_vars.is_tile:
			ghost_tile.visible = true
			var level_tilesets : LevelTilesets = load("res://assets/level_tilesets.tres")
			var tileset_info = load("res://assets/tilesets/" + level_tilesets.tilesets[global_vars.selected_tileset_id] + ".tres")
			ghost_tile.texture = tileset_info.placing_texture
			ghost_tile.region_rect = tileset_info.placing_rect
			ghost_tile.modulate = Color(1, 1, 1, 0.5)
			ghost_tile.position = Vector2(mouse_tile_pos.x * 32, mouse_tile_pos.y * 32)
		else:
			ghost_tile.visible = false
			ghost_object.visible = true
			ghost_object.modulate = Color(1, 1, 1, 0.5)
			if global_vars_node.placement_mode == "Tile":
				ghost_object.position = mouse_grid_pos
			else:
				ghost_object.position = mouse_pos
		
		var tile = global_vars.get_tile(global_vars.selected_tileset_id, global_vars.selected_tile_id)
		if mouse_screen_pos.y > 70:
			if Input.is_mouse_button_pressed(1):
				if global_vars.is_tile:
					if mouse_tile_pos.x > -1 and mouse_tile_pos.x < level_size.x:
						if mouse_tile_pos.y > -1 and mouse_tile_pos.y < level_size.y:
								if (tilemap_node.get_cell(mouse_tile_pos.x, mouse_tile_pos.y) != tile):
									tilemap_node.set_cell(mouse_tile_pos.x, mouse_tile_pos.y, tile)
									global_vars.editor.set_tile(mouse_tile_pos, global_vars.selected_tileset_id, global_vars.selected_tile_id, layer)
									tilemap_node.update_bitmask_area(Vector2(mouse_tile_pos.x, mouse_tile_pos.y))
				elif global_vars.placement_mode == "Tile":
					global_vars.editor.create_object(self, global_vars_node.selected_object_type, { "position": mouse_grid_pos, "scale": Vector2(1, 1), "rotation_degrees": 0 })
			elif Input.is_mouse_button_pressed(2):
				tilemap_node.set_cell(mouse_tile_pos.x, mouse_tile_pos.y, air_tile)
				global_vars.editor.set_tile(mouse_tile_pos, 0, 0, layer)
				tilemap_node.update_bitmask_area(Vector2(mouse_tile_pos.x, mouse_tile_pos.y))
				if layer == 1:
					global_vars.editor.delete_object_at_position(self, mouse_grid_pos)
			if global_vars.placement_mode == "Drag" && !global_vars.is_tile:
				if Input.is_action_just_pressed("click"):
					global_vars.editor.create_object(self, global_vars_node.selected_object_type, { "position": mouse_pos, "scale": Vector2(1, 1), "rotation_degrees": 0 })
				elif Input.is_action_just_pressed("right_click"):
					var objectsToDelete = []
					for object in level_objects.get_children():
						if (object.position - mouse_pos).length() <= 16:
							objectsToDelete.append(object)	
					for object in objectsToDelete:
						global_vars.editor.delete_object(object)
	else:
		ghost_tile.visible = false
		if !global_vars.is_tile:
			ghost_object.visible = false	
