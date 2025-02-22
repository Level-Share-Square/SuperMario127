extends State

class_name LavaBoostState

export var boost_velocity = 650
export var bounce_velocity = 140
export var extra_velocity = 80
var bounces_left = 0
var burn_cooldown = 0.0
var burn_sound_cooldown = 0.0
var lava_areas
var base_burn_particle_gradient = Gradient.new()


func _ready():
	base_burn_particle_gradient.colors = PoolColorArray([Color(1, 0.596078, 0), Color(0.658824, 0, 0), Color(0.082353, 0.082353, 0.082353), Color(0, 0, 0, 0)])
	base_burn_particle_gradient.offsets = PoolRealArray([0, 0.189, 0.692, 0.983])
	priority = 5
	auto_flip = true
	override_rotation = true

func _start_check(_delta):
	lava_areas = character.lava_detector.get_overlapping_areas()
	return (character.lava_detector.get_overlapping_areas().size() > 0 and character.terrain_detector.get_overlapping_bodies().size() == 0) and !(character.powerup != null and character.powerup.id == "Metal")
	
func _start(_delta):
	lava_areas = character.lava_detector.get_overlapping_areas()
	character.sprite.rotation_degrees = 0
	character.current_jump = 0
	character.friction = 4
	bounces_left = 3
	priority = 5
	for area in lava_areas:
		var area_object = area.get_parent()
		if area_object.color != Color(1, 0, 0):
			#constructs a new gradient if the color is not the base red
			var new_gradient = Gradient.new()
			new_gradient.colors = PoolColorArray([area_object.color, Color8((area_object.color.r*255)-87, (area_object.color.g*255)-87, (area_object.color.b*255)-87), Color(0.082353, 0.082353, 0.082353), Color(0, 0, 0, 0)])
			new_gradient.offsets = PoolRealArray([0, 0.189, 0.692, 0.983])
			character.burn_particles.process_material.color_ramp.gradient = new_gradient
		else:
			character.burn_particles.process_material.color_ramp.gradient = base_burn_particle_gradient
			
		#velocity application
		if area_object != CircleArea:
			#if it's not a circle then just use the angle
			if area_object.name.begins_with("Fire") or area_object.name.begins_with("@Fire"):
				character.velocity.y = -boost_velocity
			else:
				var lava_normal : Vector2 = area_object.transform.y
				
				var lava_scale_sign : Vector2 = area_object.scale.sign()
				if !is_equal_approx(lava_normal.x, 0):
					character.velocity.x = min(abs(lava_normal.x * boost_velocity), 480) * -sign(lava_normal.x)
					
				if lava_normal.y < 0:
					character.velocity.y = -boost_velocity * (lava_normal.y/2)
				else:
					character.velocity.y = -boost_velocity * (lava_normal.y/2 + .5)
				
				
		else:
			#if it is a circle find the angle from the angle to the center to the player's position
			character.velocity = Vector2.UP.rotated(atan((area_object.position.x-character.x)/(area_object.position.y-character.y))) * boost_velocity
	character.burn_particles.emitting = true
	
	
	if burn_sound_cooldown <= 0:
		character.sound_player.play_burn_sound()
		burn_sound_cooldown = 0.15
	
	if burn_cooldown <= 0:
		character.damage(3, "lava", 0)
		if character.health > 0:
			character.sound_player.play_lava_hurt_sound()
		burn_cooldown = 1
		

func _update(delta):
	var sprite = character.sprite
	sprite.animation = "lavaBoost"
	
	var offset_x = (randi() % 2) - 1
	var offset_y = (randi() % 2) - 1
	sprite.offset = Vector2(offset_x, offset_y)
	
	character.burn_particles.position.x = -2.5 * character.facing_direction

	if character.is_grounded() and bounces_left > 0:
		character.velocity.y = -(bounce_velocity + (extra_velocity * bounces_left))
		bounces_left -= 1
	
	if _start_check(delta):
		_start(delta)

func _stop(delta):
	character.burn_particles.emitting = false
	var sprite = character.sprite
	sprite.offset.y = 0
	character.friction = character.real_friction
	character.set_state_by_name("BounceState", delta)

func _stop_check(_delta):
	return bounces_left <= 0

func _general_update(delta):
	if burn_sound_cooldown > 0:
		burn_sound_cooldown -= delta
		if burn_sound_cooldown <= 0:
			burn_sound_cooldown = 0
	if burn_cooldown > 0:
		burn_cooldown -= delta
		if burn_cooldown <= 0:
			burn_cooldown = 0
