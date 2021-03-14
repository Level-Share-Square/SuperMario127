extends GameObject

onready var animated_sprite = $AnimatedSprite
onready var area = $Area2D
onready var water_detector = $WaterDetector
onready var shape = $Area2D/CollisionShape2D
onready var water_shape = $WaterDetector/CollisionShape2D
onready var visibility_enabler = $VisibilityEnabler2D

export var coins : int = 1

var collected := false
var physics := false
var blink := false
var gravity : float
var gravity_scale := 1.0
var velocity : Vector2

export var anim_fps = 12

func _set_properties():
	savable_properties = ["physics", "velocity"]
	editable_properties = ["physics", "velocity"]

func _set_property_values():
	set_property("physics", physics, true)
	set_property("velocity", velocity, true)

func collect(body, is_shell = false):
	if enabled and !collected and (body and body.name.begins_with("Character") and !body.dead) or is_shell:
		Singleton.CurrentLevelData.level_data.vars.coins_collected += coins
		if body:
			body.heal(1 if coins == 1 else 15)
		get_tree().current_scene.get_node("SharedSounds").PlaySound("CoinSound")
		collected = true
		physics = false
		animated_sprite.animation = "collect"
		animated_sprite.frame = 0
		yield(get_tree().create_timer(1.0), "timeout")
		queue_free() # die

func _ready():
	if physics:
		gravity = Singleton.CurrentLevelData.level_data.areas[Singleton.CurrentLevelData.area].settings.gravity
	
	yield(get_tree().create_timer(0.2), "timeout")
	var _connect = area.connect("body_entered", self, "collect")
	
	if physics:
		yield(get_tree().create_timer(9.0 - 0.2), "timeout")
		blink = true # Make the coin flash before disappearing
		yield(get_tree().create_timer(1.0), "timeout")
		queue_free() # die

# Sprite frame assignments seem to be expensive
var previous_frame = 0
# Additional cache variables
var prev_activate_shape = false
func _process(delta):
	if !collected:
		var new_frame = get_tree().current_scene.coin_frame
		if new_frame != previous_frame:
			animated_sprite.frame = new_frame
			previous_frame = new_frame
	if physics:
		water_shape.disabled = false
	
	# Toggle the collection shape (perf)
	if mode != 1:
		var root = get_tree().current_scene
		var activate_shape = false
		if !collected:
			var can_collect_coins = root.can_collect_coins
			for entity in can_collect_coins:
				if entity == null:
					can_collect_coins.erase(entity)
					continue
				
				var entity_global_position = entity.global_transform.get_origin()
				if (entity_global_position - position).length_squared() <= 200 + 472.25:
					activate_shape = true
		
		if activate_shape != prev_activate_shape:
			shape.disabled = !activate_shape
			prev_activate_shape = activate_shape
	
	if blink:
		visible = !visible

func horizontal_cast():
	var pos_new = position + Vector2(5 if velocity.x > 0 else -5, 0)
	return get_world_2d().direct_space_state.intersect_ray(
		position, pos_new, [self], 17)

func vertical_cast():
	var pos_new = position + Vector2(0, -10 if velocity.y < 0 else 10)
	return get_world_2d().direct_space_state.intersect_ray(
		position, pos_new, [self], 17)

func _physics_process(delta):
	# Everything else here is irrelevant for edit mode
	if mode == 1 or !visibility_enabler.is_on_screen():
		return
	
	if physics:
		if water_detector.get_overlapping_areas().size() > 0:
			gravity_scale = 0
			velocity = velocity.move_toward(Vector2.ZERO, delta * 120)
		else:
			gravity_scale = 1
		
		velocity.y += gravity * delta * 120 * gravity_scale
		position += velocity * delta
		
		var up = velocity.y < 0
		var result = vertical_cast()
		if result:
			if up:
				velocity.y = 30
				position.y += 2
			else:
				velocity.x = lerp(velocity.x, 0, delta)
				velocity.y = 0
				position.y = result.position.y - 10
		
		if abs(velocity.x) > 0.00001:
			result = horizontal_cast()
			if result:
				var x_cast = 5 if velocity.x > 0 else -5
				velocity.x = 0
				position.x = result.position.x - x_cast

func shell_hit():
	collect(null, true)

func is_coin():
	return true
