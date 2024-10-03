extends GameObject

onready var body: = $Body
onready var sprite: = $Body/Sprite
onready var particles = $Body/Particles
onready var poof_particles = $Body/PoofParticles
onready var hit_area = $Body/AttackArea

var velocity: = Vector2.ZERO
var last_velocity := Vector2.ZERO

var gravity: = 0.0
var gravity_scale: = 1.0
var delete_timer: = 0.0
var total_time: = 1.0
var bouncy := false
var bounce_count := 0

var hit: = false

func _ready():
	if mode != 1:
		gravity = Singleton.CurrentLevelData.level_data.areas[Singleton.CurrentLevelData.area].settings.gravity
		if bouncy:
			modulate = Color(0, 1, 1)
			bounce_count = 5
#			body.collision_mask = 1
		else:
			modulate = Color(1, 1, 1)
#			body.collision_mask = 0
		var _connect = hit_area.connect("body_entered", self, "damage_player")

func _set_properties():
	savable_properties = ["velocity", "bouncy"]
	editable_properties = ["velocity", "bouncy"]
	
func _set_property_values():
	set_property("velocity", velocity, true)
	set_property("bouncy", bouncy, true)

func _process(delta):
	if (delete_timer > 0):
		delete_timer -= delta
		
		if (delete_timer <= 0):
			queue_free()

func _physics_process(delta):
	if hit:
		return
	
	velocity.y += gravity * gravity_scale * (delta * 60)
	
	if body.is_on_floor():
		if bouncy:
			velocity = last_velocity.bounce(body.get_floor_normal())
			bounce_count -= 1

	last_velocity = velocity
	velocity = body.move_and_slide(velocity)

func damage_player(body):
	if body.name.begins_with("Character"):
		body.damage_with_knockback(body.global_position, 2)
		delete_fireball()

func delete_fireball():
	hit = true
	delete_timer = 1.0
	body.collision_layer = 0
	body.collision_mask = 0
	sprite.visible = false
	particles.emitting = false
	poof_particles.emitting = true
	poof_particles.restart()
