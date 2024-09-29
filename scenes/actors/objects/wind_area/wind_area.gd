extends GameObject

onready var sprite : Sprite = $Sprite


onready var area : Area2D = $Area2D
onready var collision_shape = $Area2D/CollisionShape2D
onready var particles = $Particles2D

var size := Vector2(128, 128)
var wind_power := 20.0
var color := Color(1, 1, 1, 1)
var triggerable := false

var triggered := true
var wind_angle_vector : Vector2

var max_velocity : Vector2

func _set_properties():
	savable_properties = ["size", "wind_power", "color", "triggerable"]
	editable_properties = ["size", "wind_power", "color", "triggerable"]

func _set_property_values():
	set_property("size", size, true, null)
	set_property("wind_power", wind_power, true, "Wind Strength")
	set_property("color", color)
	set_property("triggerable", triggerable)

# Called when the node enters the scene tree for the first time.
func _ready():
	if mode != 1:
		var _connect = area.connect("body_entered", self, "entered")
		var _connect2 = area.connect("body_exited", self, "exited")
		sprite.visible = false
		if triggerable:
			triggered = false
	else:
		var _connect3 = connect("property_changed", self, "update_property")
	wind_angle_vector = Vector2.UP.rotated(deg2rad(rotation_degrees)).normalized()
	update_size()

func _physics_process(delta):
	if mode != 1 and !is_preview:
		if triggered:
			particles.emitting = true
			for body in area.get_overlapping_bodies():
				if enabled and body.name.begins_with("Character") and !body.dead and body.controllable:
					body.velocity = apply_velocity(body.velocity, delta)
					#For some reason mario moves slowly towards the wind generator when on the floor and not moving
					#so we check if he's moving
					if !body.inputs[0][0] and !body.inputs[1][0]:
						#and if he's on the floor
						if body.is_on_floor():
							#and if he is we run a modified physics calculation
							if wind_angle_vector.x > 0 and body.velocity.x <= (wind_power*wind_angle_vector.x)*3:
								body.velocity.x += (wind_power*wind_angle_vector.x)*60*delta
							elif wind_angle_vector.x < 0 and body.velocity.x >= (wind_power*wind_angle_vector.x)*3:
								body.velocity.x += (wind_power*wind_angle_vector.x)*60*delta
					
					if !body.is_on_floor() and body.state is FallState:
						var char_sprite = body.sprite
						if body.facing_direction == 1:
							if body.jump_animation == 0:
								char_sprite.animation = "fallRight"
							elif body.jump_animation == 1:
								char_sprite.animation = "doubleFallRight"
						elif body.facing_direction == -1:
							if body.jump_animation == 0:
								char_sprite.animation = "fallLeft"
							elif body.jump_animation == 1:
								char_sprite.animation = "doubleFallLeft"
					
					#set's mario's state to falling if he stops going down in a ground pound
					if (body.state is GroundPoundState) and (body.velocity.y <= 0):
						if !body.is_on_floor():
							body.set_state_by_name("FallState", delta)
						
				elif enabled and !body.name.begins_with("Character"):
					var body_object = body.get_parent()
					body_object.velocity = apply_velocity(body_object.velocity, delta)
						
		else:
			particles.emitting = false
	else:
		sprite.visible == true

func apply_velocity(velocity: Vector2, delta: float) -> Vector2:
	var new_velocity := velocity
	
	# first apply the X component
	if wind_angle_vector.x > 0 and velocity.x <= (wind_power*wind_angle_vector.x)*18:
		new_velocity.x += wind_power*wind_angle_vector.x*60*delta
	elif wind_angle_vector.x < 0 and velocity.x >= (wind_power*wind_angle_vector.x)*18:
		new_velocity.x += wind_power*wind_angle_vector.x*60*delta
	
	#then the y component
	if wind_angle_vector.y > 0 and velocity.y <= (wind_power*wind_angle_vector.y)*18:
		new_velocity.y += wind_power*wind_angle_vector.y*60*delta
	elif wind_angle_vector.y < 0 and velocity.y >= (wind_power*wind_angle_vector.y)*18:
		new_velocity.y += wind_power*wind_angle_vector.y*60*delta
	
	#then return the new velocity that's been calculated. Simple! :D
	return new_velocity

func update_property(key, value):
	match(key):
		"wind_power":
			if wind_power <= 0:
				wind_power = 1
				
	update_size()

func entered(body):
	if enabled and body.name.begins_with("Character") and !body.dead and body.controllable:
		body.velocity += Vector2(wind_power, wind_power)*wind_angle_vector
	if triggerable:
		particles.preprocess = 0
		triggered = true

func exited(body):
	if enabled and body.name.begins_with("Character") and !body.dead and body.controllable:
		if wind_angle_vector.x != 0:
			body.velocity.x = body.velocity.x*.95
		if wind_angle_vector.y != 0:
			body.velocity.y = body.velocity.y*.75
	elif enabled and !body.name.begins_with("Character"):
		body.get_parent().velocity.y = body.get_parent().velocity.y*.75
	
	if triggerable:
		triggered = false

func update_size():
	collision_shape.shape.extents = size/2
	collision_shape.position.y = -collision_shape.shape.extents.y
	update_particles()

func update_particles():
	particles.visibility_rect = Rect2(-size.x-32, -(size.y)-32, size.x*2+64, size.y*2+64)
	particles.lifetime = ((size.y/20)/abs(wind_power))+.1
	particles.amount = int((size.x/48)*(size.y/48))
	particles.modulate = Color(color.r, color.g, color.b)
	particles.process_material.set_shader_param("wind_speed", abs(wind_power))
	particles.process_material.set_shader_param("size", size/2)
	particles.process_material.set_shader_param("emission_rect", Plane(0.0, 0.0, size.x/2, size.y/2))
