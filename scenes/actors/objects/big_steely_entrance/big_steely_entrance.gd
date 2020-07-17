extends GameObject

onready var steely_scene = load("res://scenes/actors/objects/big_steely/big_steely_ball.tscn")

var steely_objects = []
var spawn_timer = 0.0
var cleanout_timer = 0.0

var spawn_interval = 7.5

func _set_properties():
	savable_properties = ["spawn_interval"]
	editable_properties = ["spawn_interval"]
	
func _set_property_values():
	set_property("spawn_interval", spawn_interval, 1)

func _ready():
	cleanout_timer = 10.0
	
func _process(delta):
	if mode != 1:
		spawn_timer -= delta
		if spawn_timer <= 0:
			spawn_timer = spawn_interval
			if true: #steely_objects.size() <= 16:
				var object = LevelObject.new()
				object.type_id = 37
				object.properties = []
				object.properties.append(global_position)
				object.properties.append(scale)
				object.properties.append(0)
				object.properties.append(true)
				object.properties.append(true)
				get_parent().create_object(object, false)
				steely_objects.append(object)
