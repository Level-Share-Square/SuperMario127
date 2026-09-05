extends GameObject

onready var kinematic_body = $KinematicBody2D
onready var collision_shape = $KinematicBody2D/CollisionShape2D
onready var area = $KinematicBody2D/Area2D
onready var area_collision = $KinematicBody2D/Area2D/CollisionShape2D
onready var sound = $AudioStreamPlayer

var velocity := Vector2(0, 0)
var nozzle_type: int = 0
var collected = false
var destroy_timer = 0.0

var nozzle_map: Array = ["HoverNozzle", "RocketNozzle", "TurboNozzle"]
var rect_map: Array = [Rect2(-12, -7, 24, 14), Rect2(-5, -8, 10, 16), Rect2(-8, -6, 16, 12)]

var gravity: = 0.0
var gravity_scale: = 1.0

var run_physics := true
#
#func _set_properties():
#	savable_properties = ["velocity", "nozzle_type"]
#	editable_properties = ["velocity", "nozzle_type"]
	
func _register_properties():
	register_property(4, "velocity", velocity, true)
	register_property(5, "nozzle_type", nozzle_type, false)
	set_property_override("nozzle_type", PropertyTab.OverrideTypes.ENUM, nozzle_map)
	
func _register_property_info():
	set_property_info("velocity", PropertyInfo.new("The velocity at which this travels when spawned in.", 1, -INF, INF, ["X", "Y"], ["", ""], false, "Velocity"))
	set_property_info("nozzle_type", PropertyInfo.new("Which nozzle this is.", 1, -INF, INF, ["", ""], ["", ""], false, "Nozzle"))
	
		
func collect(body):
	if is_enabled_and_on_ground() and !collected and body.name.begins_with("Character") and !body.dead:
		sound.play()
		visible = false
		run_physics = false
		destroy_timer = 2
		body.fuel = 100
		collected = true
		body.add_nozzle(nozzle_map[nozzle_type])
		body.set_nozzle(nozzle_map[nozzle_type])

func _ready():
	gravity = CurrentLevelData.current_area.header.gravity
	kinematic_body.get_node("Sprite_" + nozzle_map[nozzle_type]).visible = true
	editor_rect = rect_map[nozzle_type]
	
func _object_ready():
	if is_enabled_and_on_ground():
		var _connect = area.connect("body_entered", self, "collect")
	
func _process(delta):
	if destroy_timer > 0:
		destroy_timer -= delta
		if destroy_timer <= 0:
			destroy_timer = 0
			queue_free()
			
func _physics_process(delta):
	if mode != 1 and run_physics:
		if velocity.y < 600:
			velocity.y += gravity * gravity_scale * 2
		
		if kinematic_body.is_on_floor():
			velocity.y = 0
		
		kinematic_body.move_and_slide_with_snap(velocity, Vector2(0, 8), Vector2.UP, true)
