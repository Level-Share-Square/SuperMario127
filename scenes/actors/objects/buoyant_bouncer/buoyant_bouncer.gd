extends GameObject


#-------------------------------- GameObject logic -----------------------


export(Array, Texture) var palette_textures


func _set_properties():
	savable_properties = ["strong_bounce_power"]
	editable_properties = ["strong_bounce_power"]
	
func _set_property_values():
	set_property("strong_bounce_power", strong_bounce_power, 650)




#-------------------------------- platform logic -----------------------
	
onready var sprite = $Sprite
onready var platform_area_collision_shape = $bouncecol/Area2D/CollisionShape2D
onready var collision_shape = $bouncecol/CollisionShape2D


var scale_x : float
export var override_part_width := 0 # If this value is not equal to 0, this'll replace part_width with it's value

var can_collide_with_floor = false

onready var animplay = $AnimationPlayer

# initialize parameters for query
onready var waterdet = $watercol
onready var grounddet = $groundcol
var water = null
var water_array : Array
var grav

var cooldown = 0

var bounce_power = 300
var strong_bounce_power = 650

onready var bouncedet = $bouncecol

func _ready():
	if palette != 0:
		$Sprite.texture = palette_textures[palette]
	print(palette)
	var editor = get_tree().current_scene
	grav = editor.level_area.settings.gravity
	print(grav)
	var _connect = waterdet.connect("area_entered", self, "water_entered")
	var _connect2 = grounddet.connect("body_entered", self, "ground_entered")
	var _connect3 = bouncedet.connect("body_entered", self, "mario_entered")
	var _connect4 = waterdet.connect("area_exited", self, "water_exited")

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
	
	if body.has_method("set_state_by_name"):
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

func water_entered(area):
	if "Col" in str(area):
		for i in waterdet.get_overlapping_areas():
			if "Water" in str(i.owner) or "Area2D" in str(i.owner):
				water_array.append(i.owner)
				can_collide_with_floor = false
		if !water_array.empty():
			water = water_array[0]
	else: return
	
func water_exited(area):
	if "Col" in str(area):
		if "Water" in str(area.owner) or "Lava" in str(area.owner):
				can_collide_with_floor = false
	water = null
	
func ground_entered(body):
	if "Middle" in str(body):
		if water != null:
			water = null
		can_collide_with_floor = true
	else:
		return
	print(body)
	
func _physics_process(delta):
	if cooldown > 0:
		cooldown -= delta
		if cooldown <= 0:
			cooldown = 0
	if !"Editor" in str(get_tree().current_scene):
		if is_instance_valid(water):
			position.y = water.position.y - 9
			animplay.play("bob")
		else:
			animplay.play("RESET")
			if can_collide_with_floor == false:
				position.y += grav
	
