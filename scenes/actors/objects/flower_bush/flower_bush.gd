extends Decoration

onready var sprite = $Sprite
onready var interaction_area = $Area2D

var displacement : float = 0.0
var displacement_spring_anim_power : float = 0.0

var base_scale_factor : float = 0.0
var scale_spring_anim_power : float = 0.0

func _ready():
	if enabled:
		interaction_area.connect("body_entered", self, "start_anim")

func _process(delta):
	if enabled:
		if !is_equal_approx(displacement_spring_anim_power, 0):
			update_displacement_spring(delta)
		else:
			sprite.material.set_shader_param("strength", 0)
		
		if !is_equal_approx(scale_spring_anim_power, 0):
			update_scale_spring(delta)
		else:
			sprite.scale = Vector2.ONE

func start_anim(body):
	var entrance_velocity := Vector2.ZERO
	
	if "velocity" in body:
		entrance_velocity = body.velocity
	elif "velocity" in body.get_parent():
		entrance_velocity = body.get_parent().velocity
	
	
	
	if sign(entrance_velocity.x) == 0:
		set_scale_spring(8)
	else:
#		set_scale_spring(-7)
		set_displacement_spring(10 * sign(entrance_velocity.x))


func set_displacement_spring(power : float):
	displacement_spring_anim_power = power

func update_displacement_spring(delta):
	var spring_constant = 800
	var damping_constant = 7
	
	var damping_ratio = damping_constant / (2 * sqrt(spring_constant))

	
	var force = (-spring_constant * displacement) + (damping_constant * displacement_spring_anim_power)
	displacement_spring_anim_power -= force * delta
	displacement -= displacement_spring_anim_power * delta
	
	sprite.material.set_shader_param("strength", displacement)


func set_scale_spring(power : float):
	scale_spring_anim_power = power

func update_scale_spring(delta):
	var spring_constant = 200
	var damping_constant = 20
	
	var damping_ratio = damping_constant / (2 * sqrt(spring_constant))
	
	var force = (-spring_constant * base_scale_factor) + (damping_constant * scale_spring_anim_power)
	scale_spring_anim_power -= force * delta
	base_scale_factor -= scale_spring_anim_power * delta
	
	sprite.scale.y = (1 + base_scale_factor)
	sprite.scale.x = 1-((sprite.scale.y-1)/2)
