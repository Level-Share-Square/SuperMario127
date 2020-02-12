extends TileMap

var levelSize = Vector2(0 ,0);

func _ready():
	var levelSizeNode = get_node("../LevelSettings");
	var levelSizeTemp = levelSizeNode.levelSize;
	levelSize = Vector2(levelSizeTemp.x * 32, levelSizeTemp.y * 32);
	pass

func _physics_process(delta):
	var globalVarsNode = get_node("../GlobalVars");
	if globalVarsNode.gameMode == "Editing":
		var mousePos = get_global_mouse_position();
		var mouseTilePos = Vector2(floor(mousePos.x / 32), floor(mousePos.y / 32));
		
		var ghostTile = get_node("../GhostTile");
		ghostTile.modulate = Color(1, 1, 1, 0.5);
		ghostTile.position = Vector2(mouseTilePos.x * 32, mouseTilePos.y * 32);
		
		if Input.is_mouse_button_pressed(1):
			if mouseTilePos.x > -1 and mouseTilePos.x < levelSize.x + 1:
				if mouseTilePos.y > -1 and mouseTilePos.x < levelSize.y + 1:
					self.set_cell(mouseTilePos.x, mouseTilePos.y, 1);
		elif Input.is_mouse_button_pressed(2):
			if mouseTilePos.x > -1 and mouseTilePos.x < levelSize.x + 1:
				if mouseTilePos.y > -1 and mouseTilePos.x < levelSize.y + 1:
					self.set_cell(mouseTilePos.x, mouseTilePos.y, -1);
