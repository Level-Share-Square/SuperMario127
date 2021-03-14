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
	var data = Singleton.CurrentLevelData.level_data
	var area = data.areas[Singleton.CurrentLevelData.area]
	
	size_label.text = "x: " + str(area.settings.bounds.size.x) + "\ny: " + str(area.settings.bounds.size.y)
	
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
	var data = Singleton.CurrentLevelData.level_data
	var area = data.areas[Singleton.CurrentLevelData.area]
	
	var amount = 1
	
	if Input.is_mouse_button_pressed(2):
		amount = 10
		
	click_sound.play()
	
	for _integer in range(amount):
		if button_left_out.pressed and area.settings.bounds.size.x < 1500:
			area.settings.bounds = area.settings.bounds.grow_individual(1,0,0,0)
			shared_node.update_tilemaps()
			camera_node.update_limits(area)
			update_label()
			
		if button_left_in.pressed and area.settings.bounds.size.x > 24:
			area.settings.bounds = area.settings.bounds.grow_individual(-1,0,0,0)
			shared_node.update_tilemaps()
			camera_node.update_limits(area)
			camera_node.position.x -= 32
			update_label()
	
		if button_right_out.pressed and area.settings.bounds.size.x < 1500:
			area.settings.bounds = area.settings.bounds.grow_individual(0,0,1,0)
			shared_node.update_tilemaps()
			camera_node.update_limits(area)
			update_label()
			
		if button_right_in.pressed and area.settings.bounds.size.x > 24:
			area.settings.bounds = area.settings.bounds.grow_individual(0,0,-1,0)
			shared_node.update_tilemaps()
			camera_node.update_limits(area)
			update_label()
	
		if button_down_out.pressed and area.settings.bounds.size.y < 1500:
			area.settings.bounds = area.settings.bounds.grow_individual(0,0,0,1)
			shared_node.update_tilemaps()
			backgrounds_node.update_background_area(area)
			camera_node.update_limits(area)
			camera_node.position.y += 32
			update_label()
			
		if button_down_in.pressed and area.settings.bounds.size.y > 14:
			area.settings.bounds = area.settings.bounds.grow_individual(0,0,0,-1)
			shared_node.update_tilemaps()
			backgrounds_node.update_background_area(area)
			camera_node.update_limits(area)
			update_label()
	
		if button_up_out.pressed and area.settings.bounds.size.y < 1500:
			area.settings.bounds = area.settings.bounds.grow_individual(0,1,0,0)
			shared_node.update_tilemaps()
			backgrounds_node.update_background_area(area)
			camera_node.update_limits(area)
			camera_node.position.y += 32
			update_label()
			
		if button_up_in.pressed and area.settings.bounds.size.y > 14:
			area.settings.bounds = area.settings.bounds.grow_individual(0,-1,0,0)
			shared_node.update_tilemaps()
			backgrounds_node.update_background_area(area)
			camera_node.update_limits(area)
			update_label()
