extends GameObject


#-------------------------------- GameObject logic -----------------------

export var parts := 1
var last_parts := 1

var physics_enabled := true

export(Array, Texture) var palette_textures


#func _set_properties():
#	savable_properties = ["strong_bounce_power", "physics_enabled"]
#	editable_properties = ["strong_bounce_power", "physics_enabled"]
	
func _register_properties():
	register_property(4, "strong_bounce_power", strong_bounce_power, true)
	register_property(5, "physics_enabled", physics_enabled, true)




#-------------------------------- platform logic -----------------------
	
onready var sprite = $BuoyancyController/Sprite
onready var platform_area = $BuoyancyController/bouncecol/Area2D
onready var platform_area_collision_shape = $BuoyancyController/bouncecol/Area2D/CollisionShape2D
onready var collision_shape = $BuoyancyController/bouncecol/CollisionShape2D
onready var buoyancy_controller = $"%BuoyancyController"

onready var left_width = sprite.patch_margin_left
onready var right_width = sprite.patch_margin_right
onready var part_width = sprite.texture.get_width() - left_width - right_width

onready var strong_bounce = preload("res://assets/sounds/note_block_strong.wav")
onready var weak_bounce = preload("res://assets/sounds/note_block_weak.wav")

onready var sound = $AudioStreamPlayer2D


var scale_x : float
export var override_part_width := 0 # If this value is not equal to 0, this'll replace part_width with it's value


var cooldown = 0

var bounce_power = 300
var strong_bounce_power = 450

onready var bouncedet = $BuoyancyController/bouncecol

var spawn_pos = Vector2(0, 0)

func _ready():
	if palette != 0:
		sprite.texture = palette_textures[palette]

	if override_part_width != 0:
		part_width = override_part_width
	
	spawn_pos = global_position
	
	if !is_enabled_and_on_ground():
		collision_shape.disabled = true
		
	buoyancy_controller.init_physics()
	bouncedet.connect("body_entered", self, "mario_entered")
	update_parts()
	
func _object_ready():
	._object_ready()
	if !is_enabled_and_on_ground():
		collision_shape.disabled = true
		
func _physics_process(delta):
	if cooldown > 0:
		cooldown -= delta
		if cooldown <= 0:
			cooldown = 0

func mario_entered(body):
	if "Character" in str(body):
		bounce(body)

func bounce(body):
	if cooldown != 0:
		return

	cooldown = 0.1
	var normal = transform.y
	
	if "velocity" in body:
		actually_bounce(body)
	elif "velocity" in body.get_parent():
		actually_bounce(body.get_parent())

func actually_bounce(body):
	var normal := transform.y
	var is_weak_bounce := true
	
	if "controllable" in body:
		if !body.controllable:
			return # Don't gbj players
	
	if body is Character:
		body.set_state_by_name("BounceState", 0)
		if body.inputs[2][0]:
			is_weak_bounce = false
			body.sound_player.play_double_jump_sound()
	
	var x_power = (-bounce_power if is_weak_bounce else -strong_bounce_power) * normal.x
	var y_power = (-bounce_power if is_weak_bounce else -strong_bounce_power) * normal.y
	
	if abs(normal.x) > 0.1:
		body.velocity.x = x_power
		# Test move to ensure the player doesn't end up inside of a tile
		if !body.has_method("test_move"):
			body.position.x += 2 * sign(x_power)
		elif !body.test_move(body.transform, Vector2(2 * sign(x_power), 0)):
			body.position.x += 2 * sign(x_power)
	if abs(normal.y) > 0.1:
		body.velocity.y = y_power
		# Test move to ensure the player doesn't end up inside of a tile
		if !body.has_method("test_move"):
			body.position.y += 2 * sign(y_power)
		elif !body.test_move(body.transform, Vector2(0, 2 * sign(y_power))):
			body.position.y += 2 * sign(y_power)
			# Bounce the player off of the ground if necessary,
			# if this wasn't done the player would stay on the ground, repeatedly bouncing
			if y_power < 0 and body.prev_is_grounded\
			and !body.test_move(body.transform, Vector2(0, 4 * sign(y_power))):
				body.position.y += 4 * sign(y_power)
	
	if "stamina" in body:
		body.stamina = 100
	
	sound.stream = weak_bounce if is_weak_bounce else strong_bounce
	sound.play()


func update_parts():
	sprite.rect_position.x = -(left_width + (part_width * parts) + right_width) / 2
	sprite.rect_size.x = left_width + right_width + part_width * parts

	platform_area_collision_shape.shape.extents.x = (left_width + (part_width * parts) + right_width) / 2 + 20
	collision_shape.shape.extents.x = (left_width + (part_width * parts) + right_width) / 2
	#calculate the total platform scale
	scale_x = scale.x * (left_width + right_width + part_width * parts) / (left_width + right_width + part_width)

func is_middle(check):
	.is_middle(check)
	
	collision_shape.disabled = !check
