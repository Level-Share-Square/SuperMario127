extends GameObject


#-------------------------------- GameObject logic -----------------------

var parts := 4
var last_parts := 4

var end_position : Vector2
var last_end_position : Vector2

var max_speed := 1.0

var curve = null

func _set_properties():
	savable_properties = ["parts", "max_speed", "curve"]
	editable_properties = ["parts", "max_speed", "end_position"]
	
func _set_property_values():
	set_property("parts", parts)
	set_property("max_speed", max_speed)
	set_property("curve", curve)
	set_property("end_position", end_position)

func _input(event):
	if event is InputEventMouseButton and event.is_pressed() and hovered:
		if event.button_index == 5: # Mouse wheel down
			parts -= 1
			if parts < 1:
				parts = 1
			set_property("parts", parts)
		elif event.button_index == 4: # Mouse wheel up
			parts += 1
			set_property("parts", parts)

func _process(_delta):
	if parts != last_parts:
		platform.set_parts(parts)
		if(mode==1):
			set_sprite_parts(start_sprite_node.get_child(0))
			set_sprite_parts(end_sprite_node.get_child(0))
		last_parts = parts
	if curve != path.curve:
		path.curve = curve
		
	if end_position != last_end_position:
		var last_index = path.curve.get_point_count()-1
		
		path.curve.set_point_position(last_index, end_position*32)
		update()
		end_sprite_node.position = path.curve.get_point_position(last_index)
		
		last_end_position = end_position



#-------------------------------- platform logic -----------------------

onready var platform = $TouchLiftPlatform
onready var path_follower = $Path2D/PathFollow2D
onready var path = $Path2D
onready var platform_sprite = $TouchLiftPlatform/Sprite

var speed := 1.0
var virtual_offset := 0.0
var time_alive = 0

onready var start_sprite_node : Node2D
onready var end_sprite_node : Node2D

const line_color = Color(1, 1, 1, 0.5)
const modulate_color : Color = Color(1, 1, 1, 0.5)

onready var left_width = platform_sprite.patch_margin_left
onready var right_width = platform_sprite.patch_margin_right
onready var part_width = platform_sprite.texture.get_width() - left_width - right_width

func _ready():
	if curve==null and path.curve==null:
		path.curve = Curve2D.new()
		path.curve.add_point(Vector2())
		path.curve.add_point(Vector2(0,-64))
	
		set_property("curve", path.curve)
	elif path.curve == null:
		path.curve = curve
	elif curve == null:
		set_property("curve", path.curve)
		
	platform.set_parts(parts)
	
	if(mode==1):
		platform.modulate = modulate_color
		
		start_sprite_node = Node2D.new()
		start_sprite_node.add_child(platform_sprite.duplicate())
		#end_sprite.add_child(platform_sprite)
		add_child(start_sprite_node)
		
		end_sprite_node = Node2D.new()
		end_sprite_node.add_child(platform_sprite.duplicate())
		end_sprite_node.modulate = modulate_color
		add_child(end_sprite_node)
		
		set_property("end_position", path.curve.get_point_position(path.curve.get_point_count()-1)/32)
		
func set_sprite_parts(sprite):
	sprite.rect_position.x = -(left_width + (part_width * parts) + right_width) / 2
	sprite.rect_size.x = left_width + right_width + part_width * parts

func _draw():
	if(mode==1):
		draw_polyline(path.curve.get_baked_points(), line_color, 2.0)

func _physics_process(_delta):
	#var desired_speed = 0
	
	virtual_offset += speed*max_speed
	path_follower.offset = path_follower.offset * 0.95 + clamp(virtual_offset, 0.0, path.curve.get_baked_length())*0.05

	if(path_follower.offset<=2.0 and speed<0.0): #platform reached an end
		speed = -speed
		virtual_offset = 0.0
	elif(path_follower.offset>=path.curve.get_baked_length()-2.0 and speed>0.0):
		speed = -speed
		virtual_offset = path.curve.get_baked_length()
		
	if(mode!=1):
		platform.set_position(path_follower.position)
	else:
		platform.position = path_follower.position
