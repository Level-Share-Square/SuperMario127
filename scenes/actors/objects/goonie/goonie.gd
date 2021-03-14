extends GameObject

onready var sprite = $Sprite

onready var platform_area_collision_shape = $StaticBody2D/Area2D/CollisionShape2D
onready var platform_area = $StaticBody2D/Area2D
onready var collision_shape = $StaticBody2D/CollisionShape2D

var last_position : Vector2
var momentum : Vector2

var speed := 1.0
var spread_timer = 5.0
var spread_end_timer = 5.0
var wings_spread = false
var spreads_started = 0

var facing_direction = 1

func _set_properties():
	savable_properties = ["speed"]
	editable_properties = ["speed"]

func _set_property_values():
	set_property("speed", speed, true)

func set_position(new_position):
	var movement = new_position - global_position
	
	#first move the bodies
	$StaticBody2D.constant_linear_velocity = movement * 60
	
	#then move self
	position = new_position

func _ready():
	$StaticBody2D/CollisionShape2D.disabled = !enabled
	spreads_started += Singleton.CurrentLevelData.enemies_instanced % 3
	Singleton.CurrentLevelData.enemies_instanced += 1
	var add_amount = 0
	if (spreads_started % 3) == 1:
		add_amount = 1.5
	elif (spreads_started % 3) == 2:
		add_amount = 0.75
	spread_timer = (3 + add_amount) / speed
	last_position = global_position
	collision_shape.shape = collision_shape.shape.duplicate()
	platform_area_collision_shape.shape = platform_area_collision_shape.shape.duplicate()
	
	facing_direction = sign(scale.x)
	scale.x = abs(scale.x)
	sprite.flip_h = true if facing_direction == 1 else false
	
	rotation_degrees = 0

func _physics_process(delta):
	momentum = (global_position - last_position) / fps_util.PHYSICS_DELTA
	last_position = global_position
	sprite.speed_scale = clamp(speed, 0.5, 3)
	sprite.playing = true
	if mode != 1 and enabled:
		if spread_timer > 0:
			spread_timer -= delta
			if spread_timer <= 0:
				wings_spread = true
				spreads_started += 1
				spread_end_timer = 1.5 / speed
		
		if spread_end_timer > 0:
			spread_end_timer -= delta
			if spread_end_timer <= 0:
				wings_spread = false
				var add_amount = 0
				if (spreads_started % 3) == 1:
					add_amount = 1.5
				elif (spreads_started % 3) == 2:
					add_amount = 0.75
				spread_timer = (3 + add_amount) / speed

		var y_pos
		if platform_area.get_overlapping_bodies().size() > 0 and platform_area.get_overlapping_bodies()[0].get_collision_layer_bit(1) == true and platform_area.get_overlapping_bodies()[0].is_grounded():
			sprite.speed_scale = clamp(speed * 2, 1, 6)
			wings_spread = false
			y_pos = global_position.y + (speed * 15 * fps_util.PHYSICS_DELTA)
		else:
			y_pos = global_position.y - (speed * 25 * fps_util.PHYSICS_DELTA)
			
		if wings_spread:
			sprite.animation = "spreadWings"
			y_pos = global_position.y + (speed * 15 * fps_util.PHYSICS_DELTA)
		else:
			sprite.animation = "flying"
			
		set_position(Vector2(global_position.x + (speed * 60 * fps_util.PHYSICS_DELTA * facing_direction), y_pos))
		
		


func _on_PlatformArea_body_exited(body):
	if body.get("velocity") != null:
		body.velocity += Vector2(momentum.x, min(0, momentum.y))
