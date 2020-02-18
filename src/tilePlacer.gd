extends TileMap

var level_size = Vector2(0 ,0)
onready var level_size_node = get_node("../LevelSettings")
onready var global_vars_node = get_node("../GlobalVars")
onready var ghost_tile = get_node("../GhostTile")

export var selected_tile:int = 3
export var selected_tile_rect:Rect2 = Rect2(96, 0, 32, 32)

func _ready():
	var level_size_temp = level_size_node.level_size
	level_size = Vector2(level_size_temp.x * 32, level_size_temp.y * 32)
	pass

func _physics_process(delta):
	if global_vars_node.game_mode == "Editing":
		var mouse_pos = get_global_mouse_position()
		var mouse_screen_pos = get_viewport().get_mouse_position()
		var mouse_tile_pos = Vector2(floor(mouse_pos.x / 32), floor(mouse_pos.y / 32))
		
		ghost_tile.modulate = Color(1, 1, 1, 0.5)
		ghost_tile.position = Vector2(mouse_tile_pos.x * 32, mouse_tile_pos.y * 32)
		if selected_tile == 2:
			ghost_tile.texture = load("res://assets/textures/tilesets/grass/tileset.png")
		else:
			ghost_tile.texture = load("res://assets/textures/tilesets/bricks/tileset.png")
		ghost_tile.region_rect = selected_tile_rect
		
		if mouse_screen_pos.y > 70:
			if Input.is_mouse_button_pressed(1):
				if mouse_tile_pos.x > -1 and mouse_tile_pos.x < level_size.x + 1:
					if mouse_tile_pos.y > -1 and mouse_tile_pos.x < level_size.y + 1:
						if self.get_cell(mouse_tile_pos.x, mouse_tile_pos.y) != selected_tile:
							self.set_cell(mouse_tile_pos.x, mouse_tile_pos.y, selected_tile)
							self.update_bitmask_area(Vector2(mouse_tile_pos.x, mouse_tile_pos.y))
			elif Input.is_mouse_button_pressed(2):
				if mouse_tile_pos.x > -1 and mouse_tile_pos.x < level_size.x + 1:
					if mouse_tile_pos.y > -1 and mouse_tile_pos.x < level_size.y + 1:
						self.set_cell(mouse_tile_pos.x, mouse_tile_pos.y, -1)
						self.update_bitmask_area(Vector2(mouse_tile_pos.x, mouse_tile_pos.y))
