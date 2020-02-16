extends Camera2D
class_name DesignerCameraFollow

export var camera_speed = 1
var last_game_mode = "None"

export var current_zoom_level = 1.0

onready var level_size_node = get_node("../LevelSettings")
onready var global_vars_node = get_node("../GlobalVars")
onready var character = get_node("../Character")

func _input(event):
	if event.is_action_pressed("zoom_in"):
		if current_zoom_level > 0.5:
			current_zoom_level -= 0.25
		self.zoom = Vector2(current_zoom_level, current_zoom_level)
	elif event.is_action_pressed("zoom_out"):
		var level_size = level_size_node.level_size
		if current_zoom_level < 1.25:
			if (768 * (current_zoom_level + 0.25)) / 32 < level_size.x:
				current_zoom_level += 0.25
		self.zoom = Vector2(current_zoom_level, current_zoom_level)

func _gamemode_changed(game_mode):
	var level_size = level_size_node.level_size
	
	self.limit_left = 0
	self.limit_right = level_size.x * 32
	if game_mode == "Editing":
		self.limit_top = -70
		var viewport_size = get_viewport_rect().size
		if (self.position.y - viewport_size.y/2) < self.limit_top:
			self.position.y = self.limit_top + viewport_size.y/2
		elif (self.position.y + viewport_size.y/2) > self.limit_bottom:
			self.position.y = self.limit_bottom - viewport_size.y/2
		if (self.position.x - viewport_size.x/2) < self.limit_left:
			self.position.x = self.limit_left + viewport_size.x/2
		elif (self.position.x + viewport_size.x/2) > self.limit_right:
			self.position.x = self.limit_right - viewport_size.x/2
	else:
		self.limit_top = 0
		self.limit_bottom = level_size.y * 32
	pass

func _physics_process(deltaTime):
	var viewport_size = get_viewport_rect().size
	if last_game_mode != global_vars_node.game_mode:
		last_game_mode = global_vars_node.game_mode
		_gamemode_changed(global_vars_node.game_mode)
		
	if global_vars_node.game_mode == "Editing":
		if Input.is_key_pressed(KEY_W) and (self.position.y - viewport_size.y/2) > self.limit_top:
			self.position -= Vector2(0, camera_speed)
		elif Input.is_key_pressed(KEY_S) and (self.position.y + viewport_size.y/2) < self.limit_bottom:
			self.position += Vector2(0, camera_speed)
		if Input.is_key_pressed(KEY_A) and (self.position.x - viewport_size.x/2) > self.limit_left:
			self.position -= Vector2(camera_speed, 0)
		elif Input.is_key_pressed(KEY_D) and (self.position.x + viewport_size.x/2) < self.limit_right:
			self.position += Vector2(camera_speed, 0)
	else:
		position = character.position
	pass
