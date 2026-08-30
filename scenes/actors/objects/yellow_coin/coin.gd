extends GameObject

onready var coin = $KinematicBody2D/Coin
onready var particles = $KinematicBody2D/Particles
onready var kinematic_body: KinematicBody2D = $KinematicBody2D
onready var area = $KinematicBody2D/Area2D
onready var water_detector = $KinematicBody2D/WaterDetector
onready var collision_shape = $KinematicBody2D/CollisionShape2D
onready var shape = $KinematicBody2D/Area2D/CollisionShape2D
onready var water_shape = $KinematicBody2D/WaterDetector/CollisionShape2D
onready var visibility_enabler: VisibilityEnabler2D = $VisibilityEnabler2D
onready var bottom_pos = $KinematicBody2D/BottomPos

export var coins : int = 1
export var sound_name: String = "CoinSound"

var collected := false
var physics := false
var blink := false
var gravity : float
var gravity_scale := 1.0
var velocity : Vector2

var frictin_coeff : float = .33
var physics_frame := true
var physics_run := false


func _register_properties():
	register_property(4, "physics", physics)
	register_property(5, "velocity", velocity)


func collect(body, is_shell = false):
	if is_enabled_and_on_ground() and !collected and (body and body.name.begins_with("Character") and !body.dead) or is_shell:
		CurrentLevelData.vars.collect_coin(coins)
		
		if body:
			body.heal(1 if coins == 1 else 15)
		
		play_shared_sound(sound_name)
		
		collected = true
		physics = false
		
		coin.hide()
		particles.show()
		particles.frame = 0
		particles.play("collect")
		
		particles.connect("animation_finished", self, "queue_free")


func _object_ready():
	._object_ready()
	var _connect = area.connect("body_entered", self, "collect")
	
	for body in area.get_overlapping_bodies():
			if is_enabled_and_on_ground() and !collected and (body and body.name.begins_with("Character") and !body.dead):
				collect(body)
	
	gravity = CurrentLevelData.current_area.header.gravity
	
#	print(collision_shape)
	
	if do_physics():
		despawn_coin()


func _object_process(delta):
	if blink:
		visible = !visible


var prev_activate_shape = false
func _object_physics_process(delta):
	if not is_on_ground_layer() or not is_enabled_and_on_ground():
		return
	
	if !do_physics() or !visibility_enabler.is_on_screen():
		return
	
	water_detector.monitoring = do_physics()
	
	if collision_shape:
		collision_shape.disabled = !do_physics()
	
	velocity = calc_physics(false, delta)
	
	kinematic_body.move_and_slide_with_snap(velocity, Vector2(0, 0), Vector2.UP, false, 8, deg2rad(56))
	
	if velocity.y > 0:
		toggle_terrain_collision(true)
	
	if not visibility_enabler.global_position.is_equal_approx(kinematic_body.global_position):
		visibility_enabler.global_position = kinematic_body.global_position


func horizontal_cast():
	var pos_new = position + Vector2(5 if velocity.x > 0 else -5, 0)
	return get_world_2d().direct_space_state.intersect_ray(
		position, pos_new, [self], 17)


func vertical_cast():
	var pos_new = position + Vector2(0, -10 if velocity.y < 0 else 10)
	return get_world_2d().direct_space_state.intersect_ray(
		position, pos_new, [self], 17)


func despawn_coin():
	yield(get_tree().create_timer(9.0 - 0.2, false), "timeout")
	blink = true # Make the coin flash before disappearing
	yield(get_tree().create_timer(1.0, false), "timeout")
	queue_free() # die


func calc_physics(interp: bool, delta) -> Vector2:
	var new_velocity := velocity
	#changes whether physics is being run every frame or not
	var interp_scale : int = 1 if interp == false else 2
	
	#if in water slow velocity down to zero gradually
	if water_detector.get_overlapping_areas().size() > 0:
#		print("water :D")
		gravity_scale = 0.25
	else:
		gravity_scale = 1
	
	#friction calculations
	new_velocity.x -= sign(new_velocity.x) * frictin_coeff * interp_scale * delta * 60
	
	#gravity calculations
	
	if velocity.y < 600:
		new_velocity.y += gravity * gravity_scale * 2 * interp_scale * delta * 60
	
	#if on the floor, set the Y velocity to zero so it doesn't stack
	if kinematic_body.is_on_floor():
		new_velocity.y = 0
	
	return new_velocity


func toggle_terrain_collision(state: bool) -> void:
	get_node("KinematicBody2D").set_collision_mask_bit(0, state)


func shell_hit():
	collect(null, true)


func is_coin():
	return true


func do_physics() -> bool:
	return physics and mode != 1
