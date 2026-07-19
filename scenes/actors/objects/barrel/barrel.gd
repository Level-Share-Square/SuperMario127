extends GameObject

const ACCEL := 15
const DECEL := 10
const SPEED_DAMPEN := 20
const INIT_VEL := 100

onready var sprite : AnimatedSprite = $BarrelBody/Sprite
onready var sprite_color : AnimatedSprite = $BarrelBody/Sprite/Color
onready var attack_area : Area2D = $BarrelBody/AttackArea
onready var stomp_area : Area2D = $BarrelBody/StompArea
onready var water_detector : Area2D = $BarrelBody/WaterDetector
onready var visibility_notifier : VisibilityNotifier2D = $BarrelBody/VisibilityNotifier2D

onready var body : KinematicBody2D = $BarrelBody

var gravity : float
var gravity_scale : float
var velocity := Vector2()
var snap := Vector2(0, 12)

var is_rolling = false

var color := Color.white
var max_speed := 560

func _set_properties():
	savable_properties = ["color", "max_speed"]
	editable_properties = ["color", "max_speed"]

func _set_property_values():
	set_property("color", color, true)
	set_property("max_speed", max_speed, true)

func _ready() -> void:
	CurrentLevelData.enemies_instanced += 1
	gravity = CurrentLevelData.area.header.gravity
	sprite_color.modulate = color
	
	water_detector.connect("area_entered", self, "on_water_entered")
	water_detector.connect("area_exited", self, "on_water_exited")
	
	attack_area.connect("body_entered", self, "on_body_entered")

func _physics_process(delta):
	if velocity.y < max_speed:
		velocity.y += gravity * delta
	else:
		velocity.y = max_speed
		
	body.move_and_slide_with_snap(velocity, snap, Vector2.UP)
	
	if is_rolling:
		rolling(delta)
	else:
		stationary(delta)
		
func stationary(delta):
	pass
		
func rolling(delta):
	var overlapping_bodies: Array = attack_area.get_overlapping_bodies()
	var pushed: bool = false
	
	for body in overlapping_bodies:
		if "velocity" in body:
			move_body(body)
			pushed = true
			
	if !pushed:
		velocity.x = move_toward(velocity.x, 0, DECEL)
		
	if body.is_on_wall():
		velocity.x = -sign(velocity.x) * 100
	if body.is_on_floor():
		velocity.y = 0
		
func move_body(entered_body):
	velocity.x += entered_body.velocity.x / SPEED_DAMPEN
	velocity.x = clamp(velocity.x, -max_speed, max_speed)
		
func on_body_entered(entered_body):
	begin_roll(sign(entered_body.velocity.x))

func begin_roll(direction):
	is_rolling = true
	velocity.x = INIT_VEL * direction
	sprite.play("rolling")
	sprite_color.play("rolling")

func on_water_entered(area):
	gravity_scale = 0.3
	gravity = CurrentLevelData.area.header.gravity * gravity_scale
	
func on_water_exited(area):
	gravity_scale = 1
	gravity = CurrentLevelData.area.header.gravity * gravity_scale
