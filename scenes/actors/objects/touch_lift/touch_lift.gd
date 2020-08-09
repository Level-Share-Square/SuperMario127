extends GameObject

onready var platform = $Path2D/PathFollow2D/TouchLiftPlatform
onready var path_follower = $Path2D/PathFollow2D
onready var path = $Path2D
onready var platform_sprite = $Path2D/PathFollow2D/TouchLiftPlatform/Sprite

var speed := 1.5
var virtual_offset := 0.0

var time_alive = 0

onready var start_sprite : CanvasItem = platform_sprite.duplicate()
onready var end_sprite : CanvasItem = platform_sprite.duplicate()

const line_color = Color(1, 1, 1, 0.5)

func _ready():
	if(path.curve==null):
		path.curve = Curve2D.new()
		path.curve.add_point(Vector2())
		path.curve.add_point(Vector2(0,64))
	
	if(mode==1):
		platform_sprite.modulate = Color(1, 1, 1, 0.5)
		add_child(start_sprite)
		end_sprite.modulate = Color(1, 1, 1, 0.5)
		end_sprite.position = path.curve.get_point_position(path.curve.get_point_count()-1)
		add_child(end_sprite)

func _draw():
	if(mode==1):
		draw_polyline(path.curve.get_baked_points(), line_color, 2.0)

func _physics_process(_delta):
	virtual_offset += speed
	path_follower.offset = path_follower.offset * 0.95 + clamp(virtual_offset, 0.0, path.curve.get_baked_length())*0.05

	if(path_follower.offset<=2.0 and speed<0.0): #platform reached an end
		speed = -speed
		virtual_offset = 0.0
	elif(path_follower.offset>=path.curve.get_baked_length()-2.0 and speed>0.0):
		speed = -speed
		virtual_offset = path.curve.get_baked_length()
