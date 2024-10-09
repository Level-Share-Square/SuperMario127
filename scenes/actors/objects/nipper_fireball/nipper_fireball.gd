extends GameObject

onready var body: = $Body
onready var sprite: = $Body/Sprite
onready var particles = $Body/Particles
onready var poof_particles = $Body/PoofParticles
onready var hit_area = $Body/AttackArea
onready var floor_check = $Body/FloorCheck

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
			bounce_count = 2
			body.set_collision_mask_bit(0, true)
		else:
			modulate = Color(1, 1, 1)
			body.set_collision_mask_bit(0, false)
		var _connect = hit_area.connect("body_entered", self, "damage_player")
		_connect = poof_particles.connect("finished", self, "queue_free")

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
	
	velocity.y += gravity * gravity_scale
	
	var collision = body.move_and_collide(velocity*delta)
	if collision:
		if bouncy:
			if bounce_count > 0:
				velocity = last_velocity.bounce(collision.normal)/1.2
				bounce_count -= 1
			else:
				delete_fireball()

	last_velocity = velocity

func damage_player(character):
	if character.name.begins_with("Character"):
		if character.powerup != MetalPowerup or VanishPowerup:
			character.damage_with_knockback(body.global_position, 2, "hit", 90)
			delete_fireball()

func delete_fireball():
	hit = true
	delete_timer = 1.0
	body.set_collision_layer_bit(1, false)
	body.set_collision_mask_bit(1, false)
	hit_area.set_deferred("disabled", true)
	sprite.visible = false
	particles.emitting = false
	poof_particles.emitting = true
