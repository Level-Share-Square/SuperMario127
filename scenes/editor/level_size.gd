extends Control

# have fun reading this messy af code

export var shared_node_path : NodePath
onready var shared_node = get_node(shared_node_path)

export var backgrounds_node_path : NodePath
onready var backgrounds_node = get_node(backgrounds_node_path)

export var camera_node_path : NodePath
onready var camera_node = get_node(camera_node_path)

onready var size_label = $Middle/Label

onready var button_left_out = $Buttons/Left/Out
onready var button_left_in = $Buttons/Left/In

onready var button_right_out = $Buttons/Right/Out
onready var button_right_in = $Buttons/Right/In

onready var button_down_out = $Buttons/Down/Out
onready var button_down_in = $Buttons/Down/In

onready var button_up_out = $Buttons/Up/Out
onready var button_up_in = $Buttons/Up/In

onready var hover_sound = $HoverSound
onready var click_sound = $ClickSound

func update_label():
	var data = CurrentLevelData.level_data
	var area = data.areas[CurrentLevelData.area]
	
	size_label.text = "x: " + str(area.settings.size.x) + "\ny: " + str(area.settings.size.y)
	
func _ready():
	var _connect = button_left_out.connect("pressed", self, "button_press")
	var _connect2 = button_left_in.connect("pressed", self, "button_press")
	
	var _connect3 = button_right_out.connect("pressed", self, "button_press")
	var _connect4 = button_right_in.connect("pressed", self, "button_press")
	
	var _connect5 = button_down_out.connect("pressed", self, "button_press")
	var _connect6 = button_down_in.connect("pressed", self, "button_press")
	
	var _connect7 = button_up_out.connect("pressed", self, "button_press")
	var _connect8 = button_up_in.connect("pressed", self, "button_press")
	
	var _connect9 = button_left_out.connect("mouse_entered", self, "button_hovered")
	var _connect10 = button_left_in.connect("mouse_entered", self, "button_hovered")
	
	var _connect11 = button_right_out.connect("mouse_entered", self, "button_hovered")
	var _connect12 = button_right_in.connect("mouse_entered", self, "button_hovered")
	
	var _connect13 = button_down_out.connect("mouse_entered", self, "button_hovered")
	var _connect14 = button_down_in.connect("mouse_entered", self, "button_hovered")
	
	var _connect15 = button_up_out.connect("mouse_entered", self, "button_hovered")
	var _connect16 = button_up_in.connect("mouse_entered", self, "button_hovered")
	update_label()
	
func button_hovered():
	hover_sound.play()

func button_press():
	var data = CurrentLevelData.level_data
	var area = data.areas[CurrentLevelData.area]
	
	var amount = 1
	
	if Input.is_mouse_button_pressed(2):
		amount = 10
		
	click_sound.play()
	
	for _integer in range(amount):
		if button_left_out.pressed and area.settings.size.x < 1500:
			shared_node.move_all_objects_by(Vector2(32, 0))
			area.very_background_tiles = tile_util.expand_left(area, area.very_background_tiles)
			area.background_tiles = tile_util.expand_left(area, area.background_tiles)
			area.foreground_tiles = tile_util.expand_left(area, area.foreground_tiles)
			area.very_foreground_tiles = tile_util.expand_left(area, area.very_foreground_tiles)
			area.settings.size.x += 1
			shared_node.update_tilemaps()
			camera_node.update_limits(area)
			update_label()
			
		if button_left_in.pressed and area.settings.size.x > 24:
			shared_node.move_all_objects_by(Vector2(-32, 0))
			area.very_background_tiles = tile_util.shrink_left(area, area.very_background_tiles)
			area.background_tiles = tile_util.shrink_left(area, area.background_tiles)
			area.foreground_tiles = tile_util.shrink_left(area, area.foreground_tiles)
			area.very_foreground_tiles = tile_util.shrink_left(area, area.very_foreground_tiles)
			area.settings.size.x -= 1
			shared_node.update_tilemaps()
			camera_node.update_limits(area)
			camera_node.position.x -= 32
			update_label()
	
		if button_right_out.pressed and area.settings.size.x < 1500:
			area.very_background_tiles = tile_util.expand_right(area, area.very_background_tiles)
			area.background_tiles = tile_util.expand_right(area, area.background_tiles)
			area.foreground_tiles = tile_util.expand_right(area, area.foreground_tiles)
			area.very_foreground_tiles = tile_util.expand_right(area, area.very_foreground_tiles)
			area.settings.size.x += 1
			shared_node.update_tilemaps()
			camera_node.update_limits(area)
			update_label()
			
		if button_right_in.pressed and area.settings.size.x > 24:
			area.very_background_tiles = tile_util.shrink_right(area, area.very_background_tiles)
			area.background_tiles = tile_util.shrink_right(area, area.background_tiles)
			area.foreground_tiles = tile_util.shrink_right(area, area.foreground_tiles)
			area.very_foreground_tiles = tile_util.shrink_right(area, area.very_foreground_tiles)
			area.settings.size.x -= 1
			shared_node.update_tilemaps()
			camera_node.update_limits(area)
			update_label()
	
		if button_down_out.pressed and area.settings.size.y < 1500:
			area.very_background_tiles = tile_util.expand_down(area, area.very_background_tiles)
			area.background_tiles = tile_util.expand_down(area, area.background_tiles)
			area.foreground_tiles = tile_util.expand_down(area, area.foreground_tiles)
			area.very_foreground_tiles = tile_util.expand_down(area, area.very_foreground_tiles)
			area.settings.size.y += 1
			shared_node.update_tilemaps()
			backgrounds_node.update_background(area)
			camera_node.update_limits(area)
			camera_node.position.y += 32
			update_label()
			
		if button_down_in.pressed and area.settings.size.y > 14:
			area.very_background_tiles = tile_util.shrink_down(area, area.very_background_tiles)
			area.background_tiles = tile_util.shrink_down(area, area.background_tiles)
			area.foreground_tiles = tile_util.shrink_down(area, area.foreground_tiles)
			area.very_foreground_tiles = tile_util.shrink_down(area, area.very_foreground_tiles)
			area.settings.size.y -= 1
			shared_node.update_tilemaps()
			backgrounds_node.update_background(area)
			camera_node.update_limits(area)
			update_label()
	
		if button_up_out.pressed and area.settings.size.y < 1500:
			shared_node.move_all_objects_by(Vector2(0, 32))
			area.very_background_tiles = tile_util.expand_up(area, area.very_background_tiles)
			area.background_tiles = tile_util.expand_up(area, area.background_tiles)
			area.foreground_tiles = tile_util.expand_up(area, area.foreground_tiles)
			area.very_foreground_tiles = tile_util.expand_up(area, area.very_foreground_tiles)
			area.settings.size.y += 1
			shared_node.update_tilemaps()
			backgrounds_node.update_background(area)
			camera_node.update_limits(area)
			camera_node.position.y += 32
			update_label()
			
		if button_up_in.pressed and area.settings.size.y > 14:
			shared_node.move_all_objects_by(Vector2(0, -32))
			area.very_background_tiles = tile_util.shrink_up(area, area.very_background_tiles)
			area.background_tiles = tile_util.shrink_up(area, area.background_tiles)
			area.foreground_tiles = tile_util.shrink_up(area, area.foreground_tiles)
			area.very_foreground_tiles = tile_util.shrink_up(area, area.very_foreground_tiles)
			area.settings.size.y -= 1
			shared_node.update_tilemaps()
			backgrounds_node.update_background(area)
			camera_node.update_limits(area)
			update_label()
