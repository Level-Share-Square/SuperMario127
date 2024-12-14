extends GameObject

onready var kinematic_body = $KinematicBody2D
onready var collision_shape = $KinematicBody2D/CollisionShape2D
onready var area = $KinematicBody2D/Area2D
onready var area_collision = $KinematicBody2D/Area2D/CollisionShape2D
onready var sound = $AudioStreamPlayer

var velocity := Vector2(0, 0)
var nozzle_type = "HoverNozzle"
var collected = false
var destroy_timer = 0.0

var gravity: = 0.0
var gravity_scale: = 1.0

func _set_properties():
	savable_properties = ["velocity", "nozzle_type"]
	editable_properties = ["velocity", "nozzle_type"]
	
func _set_property_values():
	set_property("velocity", velocity, 1)
		
func collect(body):
	if enabled and !collected and body.name.begins_with("Character") and !body.dead:
		sound.play()
		kinematic_body.visible = false
		destroy_timer = 2
		body.fuel = 100
		collected = true
		body.add_nozzle(nozzle_type)
		body.set_nozzle(nozzle_type)

func _ready():
	var _connect = area.connect("body_entered", self, "collect")
	gravity = Singleton.CurrentLevelData.level_data.areas[Singleton.CurrentLevelData.area].settings.gravity
	kinematic_body.get_node("Sprite_" + nozzle_type).visible = true
	
func _process(delta):
	if destroy_timer > 0:
		destroy_timer -= delta
		if destroy_timer <= 0:
			destroy_timer = 0
			queue_free()
			
func _physics_process(delta):
	if mode != 1:
		if velocity.y < 600:
			velocity.y += gravity * gravity_scale * 2
		
		if kinematic_body.is_on_floor():
			velocity.y = 0
		
		kinematic_body.move_and_slide_with_snap(velocity, Vector2(0, 8), Vector2.UP, true)
