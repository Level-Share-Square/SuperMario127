extends Camera2D
class_name DesignerCameraFollow

export var cameraSpeed = 1;
var lastGameMode = "None";

export var currentZoomLevel = 1.0;

func _input(event):
	if event.is_action_pressed("zoom_in"):
		if currentZoomLevel > 0.5:
			currentZoomLevel -= 0.25;
		self.zoom = Vector2(currentZoomLevel, currentZoomLevel);
	elif event.is_action_pressed("zoom_out"):
		var levelSizeNode = get_node("../LevelSettings");
		var levelSize = levelSizeNode.levelSize;
		if currentZoomLevel < 1.25:
			if (768 * (currentZoomLevel + 0.25)) / 32 < levelSize.x:
				currentZoomLevel += 0.25;
		self.zoom = Vector2(currentZoomLevel, currentZoomLevel);

func _gamemode_changed(gameMode):
	var levelSizeNode = get_node("../LevelSettings");
	var levelSize = levelSizeNode.levelSize;
	
	limit_left = 0;
	limit_right = levelSize.x * 32;
	if gameMode == "Editing":
		limit_top = -80;
	else:
		limit_top = 0;
		limit_bottom = levelSize.y * 32;
	pass

func _physics_process(deltaTime):
	var viewportSize = get_viewport_rect().size;
	var globalVarsNode = get_node("../GlobalVars");
	if lastGameMode != globalVarsNode.gameMode:
		lastGameMode = globalVarsNode.gameMode;
		_gamemode_changed(globalVarsNode.gameMode);
		
	if globalVarsNode.gameMode == "Editing":
		if Input.is_key_pressed(KEY_W) and self.position.y > self.limit_top:
			self.position -= Vector2(0, cameraSpeed);
		elif Input.is_key_pressed(KEY_S) and (self.position.y + viewportSize.y) < self.limit_bottom:
			self.position += Vector2(0, cameraSpeed);
		if Input.is_key_pressed(KEY_A) and self.position.x > self.limit_left:
			self.position -= Vector2(cameraSpeed, 0);
		elif Input.is_key_pressed(KEY_D) and (self.position.x + viewportSize.x) < self.limit_right:
			self.position += Vector2(cameraSpeed, 0);
	else:
		var mario = get_node("../Mario");
		position = mario.position;
	pass
