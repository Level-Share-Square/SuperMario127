extends GameObject

onready var body: = $Body
onready var sprite: = $Body/Sprite
onready var particles = $Body/Particles
onready var poof_particles = $Body/PoofParticles

var velocity: = Vector2.ZERO

var gravity: = 0.0
var gravity_scale: = 1.0
var delete_timer: = 0.0
var total_time: = 1.0

var hit: = false

func _ready():
	gravity = Singleton.CurrentLevelData.level_data.areas[Singleton.CurrentLevelData.area].settings.gravity

func _set_properties():
	savable_properties = ["velocity"]
	editable_properties = ["velocity"]
	
func _set_property_values():
	set_property("velocity", velocity, true)

func _process(delta):
	if (delete_timer > 0):
		delete_timer -= delta
		
		if (delete_timer <= 0):
			queue_free()

func _physics_process(delta):
	if (hit):
		return
	
	velocity.y += gravity * gravity_scale
	
	var slide_count = body.get_slide_count()
	if (slide_count > 0):
		for i in range(slide_count):
			var collision = body.get_slide_collision(i)
			collision.collider.damage_with_knockback(body.global_position)
		
		hit = true
		delete_timer = 1.0
		body.collision_layer = 0
		body.collision_mask = 0
		sprite.visible = false
		particles.emitting = false
		poof_particles.emitting = true
		poof_particles.restart()
	
	velocity = body.move_and_slide(velocity)
