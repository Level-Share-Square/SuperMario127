extends GameObject

onready var rigid_body = $RigidBody2D
onready var collision_shape = $RigidBody2D/CollisionShape2D
onready var area = $RigidBody2D/Area2D
onready var area_collision = $RigidBody2D/Area2D/CollisionShape2D
onready var sound = $AudioStreamPlayer

var velocity := Vector2(0, 0)
var nozzle_type = "HoverNozzle"
var collected = false
var destroy_timer = 0.0

func _set_properties():
	savable_properties = ["velocity", "nozzle_type"]
	editable_properties = ["velocity", "nozzle_type"]
	
func _set_property_values():
	set_property("velocity", velocity, 1)
	if rigid_body != null:
		rigid_body.linear_velocity = velocity
	else:
		yield(self, "ready")
		rigid_body.linear_velocity = velocity
		
func collect(body):
	if enabled and !collected and body.name.begins_with("Character") and !body.dead:
		sound.play()
		rigid_body.queue_free()
		destroy_timer = 2
		body.fuel = 100
		collected = true
		body.add_nozzle(nozzle_type)
		body.set_nozzle(nozzle_type)

func _ready():
	var _connect = area.connect("body_entered", self, "collect")
	rigid_body.get_node("Sprite_" + nozzle_type).visible = true
	
func _process(delta):
	if destroy_timer > 0:
		destroy_timer -= delta
		if destroy_timer <= 0:
			destroy_timer = 0
			queue_free()
