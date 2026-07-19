extends GameObject
class_name Barrel

const ACCEL := 15
const DECEL := 2
const PUSH_VEL := 250
const LERP_STRENGTH := 0.08
const SQUISH_STRENGTH := 1.2
const HOP_HEIGHT := 100
const ROLL_BUFFER_DURATION := 10

onready var sprite : AnimatedSprite = $BarrelBody/Sprite
onready var sprite_color : AnimatedSprite = $BarrelBody/Sprite/Color
onready var attack_area : Area2D = $BarrelBody/AttackArea
onready var stomp_area : Area2D = $BarrelBody/StompArea
onready var water_detector : Area2D = $BarrelBody/WaterDetector
onready var visibility_notifier : VisibilityNotifier2D = $BarrelBody/VisibilityNotifier2D
onready var dust = $"%DustLandParticles"
onready var hop_sound = $"%HopSound"


onready var body : KinematicBody2D = $BarrelBody

var gravity : float
var gravity_scale : float
var velocity := Vector2()
var snap := Vector2(0, 1)

var is_rolling = false

var color := Color.white
var max_speed := 1000
var physics = true
var autoroll = true
var roll_buffer: float = ROLL_BUFFER_DURATION

func _set_properties():
	savable_properties = ["color", "max_speed", "physics", "autoroll"]
	editable_properties = ["color", "max_speed", "physics", "autoroll"]

func _set_property_values():
	set_property("color", color, true)
	set_property("max_speed", max_speed, true)
	set_property("physics", physics, true)
	set_property("autoroll", autoroll, true)
	

func _ready() -> void:
	CurrentLevelData.enemies_instanced += 1
	gravity = CurrentLevelData.area.header.gravity*100
	sprite_color.modulate = color
	sprite.play("default")
	sprite_color.play("default")
	water_detector.connect("area_entered", self, "on_water_entered")
	water_detector.connect("area_exited", self, "on_water_exited")
	
	attack_area.connect("body_entered", self, "on_body_entered")
	
	if autoroll:
		is_rolling = true
		sprite.play("rolling")
		sprite_color.play("rolling")

func _object_ground_physics_process(delta):
	if roll_buffer >= 0:
		roll_buffer -= 1
		
	sprite.scale = sprite.scale.move_toward(Vector2(1, 1), LERP_STRENGTH)
	sprite_color.scale = sprite.scale.move_toward(Vector2(1, 1), LERP_STRENGTH)
		
	dust.global_position = body.global_position
		
		
	sprite.speed_scale = abs(10*velocity.x) / max_speed
	sprite_color.speed_scale = abs(10*velocity.x) / max_speed
	if physics:
		if velocity.y < max_speed:
			velocity.y += gravity*delta
		else:
			velocity.y = max_speed
		if is_rolling:
			rolling(delta)
		else:
			stationary(delta)
		
func stationary(delta):
	velocity = body.move_and_slide(velocity, Vector2.UP, true)
		
func rolling(delta):
	velocity = body.move_and_slide_with_snap(velocity, snap, Vector2.UP)
	
	var overlapping_bodies: Array = attack_area.get_overlapping_bodies()

	for body in overlapping_bodies:
		if "Barrel" in body.get_parent().name: #im so sorry
			body = body.get_parent()
				
		if "velocity" in body and body != self:
			if !is_zero_approx(body.velocity.x) and is_zero_approx(velocity.x):
				roll(body)

	velocity.x = move_toward(velocity.x, 0, DECEL)
		
func move_body(entered_body):
	velocity.x += PUSH_VEL * sign(entered_body.velocity.x)
	velocity.x = clamp(velocity.x, -max_speed, max_speed)
	sprite.scale = Vector2(SQUISH_STRENGTH, SQUISH_STRENGTH)
	sprite_color.scale = Vector2(SQUISH_STRENGTH, SQUISH_STRENGTH)
		
func on_body_entered(entered_body):
	if is_rolling:
		return
	if "Barrel" in entered_body.get_parent().name: #im so sorry
		entered_body = entered_body.get_parent()
	if "velocity" in entered_body and entered_body != self:
		if !is_zero_approx(entered_body.velocity.x):
			roll(entered_body)

func roll(entered_body):
	if roll_buffer > 0:
		return
	var direction = sign(entered_body.velocity.x)
	if (direction == 1 and entered_body.global_position.x > body.global_position.x) or (direction == -1 and entered_body.global_position.x < body.global_position.x):
		return
	
	is_rolling = true
	
	velocity.x = PUSH_VEL * direction
	velocity.x = clamp(velocity.x, -max_speed, max_speed)
	velocity.y = -HOP_HEIGHT
	
	sprite.scale = Vector2(SQUISH_STRENGTH, SQUISH_STRENGTH)
	sprite_color.scale = Vector2(SQUISH_STRENGTH, SQUISH_STRENGTH)
	sprite.play("rolling")
	sprite_color.play("rolling")
	
	dust.restart()
	dust.emitting = true
	hop_sound.play()
	
	roll_buffer = ROLL_BUFFER_DURATION
	

func on_water_entered(area):
	gravity_scale = 0.3
	gravity = CurrentLevelData.area.header.gravity * gravity_scale * 100
	
func on_water_exited(area):
	gravity_scale = 1
	gravity = CurrentLevelData.area.header.gravity * gravity_scale * 100
