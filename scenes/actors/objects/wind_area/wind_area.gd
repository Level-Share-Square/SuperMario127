extends GameObject

onready var sprite : Sprite = $Sprite


onready var area : Area2D = $Area2D
onready var collision_shape = $Area2D/CollisionShape2D
onready var particles = $Particles2D

var size := Vector2(64, 64)
var wind_power := 20.0
var color := Color(255, 255, 255, 255)
var triggerable := false

var triggered := true
var wind_angle_vector : Vector2

var max_velocity : Vector2

func _set_properties():
	savable_properties = ["size", "wind_power", "color", "triggerable"]
	editable_properties = ["size", "wind_power", "color", "triggerable"]

func _set_property_values():
	set_property("size", size, true, null, ["base"])
	set_property("wind_power", wind_power)
	set_property("color", color)
	set_property("triggerable", triggerable)

# Called when the node enters the scene tree for the first time.
func _ready():
	if mode != 1:
		var _connect = area.connect("body_entered", self, "entered")
		var _connect2 = area.connect("body_exited", self, "exited")
		sprite.visible = false
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
					if wind_angle_vector.x > 0:
						if body.velocity.x < (wind_power*wind_angle_vector.x)*18:
							body.velocity.x = body.velocity.x + (wind_power*wind_angle_vector.x)
					else:
						if body.velocity.x > (wind_power*wind_angle_vector.x)*18:
							body.velocity.x = body.velocity.x + (wind_power*wind_angle_vector.x)
					
					if wind_angle_vector.y > 0:
						if body.velocity.y < (wind_power*wind_angle_vector.y)*18:
							body.velocity.y = body.velocity.y + (wind_power*wind_angle_vector.y)
					else:
						if body.velocity.y > (wind_power*wind_angle_vector.y)*18:
							body.velocity.y = body.velocity.y + (wind_power*wind_angle_vector.y)
					
					if (body.state is GroundPoundState) and (body.velocity.y <= 0):
						if !body.is_on_floor():
							body.set_state_by_name("FallState", delta)
							
					if body.is_on_floor():
						body.set_state_by_name("FallState", delta)
						
					max_velocity = body.velocity
						
				elif enabled and !body.name.begins_with("Character"):
					if wind_angle_vector.x > 0:
						if body.get_parent().velocity.x < (wind_power*wind_angle_vector.x)*18:
							body.get_parent().velocity.x = body.get_parent().velocity.x + (wind_power*wind_angle_vector.x)
					else:
						if body.get_parent().velocity.x > (wind_power*wind_angle_vector.x)*18:
							body.get_parent().velocity.x = body.get_parent().velocity.x + (wind_power*wind_angle_vector.x)
					
					if wind_angle_vector.y > 0:
						if body.get_parent().velocity.y < (wind_power*wind_angle_vector.y)*18:
							body.get_parent().velocity.y = body.get_parent().velocity.y + (wind_power*wind_angle_vector.y)
					else:
						if body.get_parent().velocity.y > (wind_power*wind_angle_vector.y)*18:
							body.get_parent().velocity.y = body.get_parent().velocity.y + (wind_power*wind_angle_vector.y)
		else:
			particles.emitting = false
	else:
		sprite.visible == true

func update_property(key, value):
	update_size()

func entered(body):
	if triggerable:
		triggered = true

func exited(body):
	if enabled and body.name.begins_with("Character") and !body.dead and body.controllable:
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
	particles.visibility_rect = Rect2(-size.x*2, -size.y*2, size.x*2, size.y*2)
	particles.lifetime = ((size.y/20)/wind_power)+.1
	particles.amount = int((size.x/32)*(size.y/32))*2
	particles.modulate = Color(color.r, color.g, color.b)
	particles.process_material.set_shader_param("wind_speed", wind_power)
	particles.process_material.set_shader_param("size", size/2)
	particles.process_material.set_shader_param("emission_rect", Plane(0.0, 0.0, size.x/2, size.y/2))
