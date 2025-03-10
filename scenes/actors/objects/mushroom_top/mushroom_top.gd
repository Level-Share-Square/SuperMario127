extends GameObject

export var custom_preview_position = Vector2(70, 170)
onready var collision_shape = $StaticBody2D/CollisionShape2D
onready var area_2d : Area2D = $StaticBody2D/Area2D
onready var bounce_area_collision : CollisionShape2D = $StaticBody2D/Area2D/CollisionShape2D
onready var animation_player : AnimationPlayer = $AnimationPlayer
onready var mushroom_cap : Sprite = $Sprite
onready var mushroom_cap_color : Sprite = $Sprite/Color
onready var resizeable_cap : NinePatchRect = $Node2D/Resizeable
onready var resizeable_cap_color : NinePatchRect = $Node2D/Resizeable/ResizableColor
onready var sound : AudioStreamPlayer = $AudioStreamPlayer
onready var visibility_enabler : VisibilityEnabler2D = $VisibilityEnabler2D
onready var timer : Timer = $IdleBounceTimer

export var weak_bounce_sound : AudioStream
export var bounce_sound : AudioStream

var bounce_power = 300
var blacklisted_bodies := {}

var color := Color(1, 0, 0)
var bouncy := false
var strong_bounce_power : int = 650
var parts : int = 0

var base_scale_factor : float = 0.0
var spring_anim_power : float = 0.0

func _set_properties():
	savable_properties = ["color", "bouncy", "strong_bounce_power", "parts"]
	editable_properties = ["parts", "color", "bouncy", "strong_bounce_power"]
	
func _set_property_values():
	set_property("color", color, true)
	set_property("bouncy", bouncy, true)
	set_property("strong_bounce_power", strong_bounce_power, true)
	set_property("parts", parts, true)

func _ready():
	var _connect = connect("property_changed", self, "update_property")
	if bouncy and enabled and mode == 0:
		_connect = timer.connect("timeout", self, "idle_bounce_anim")
		_connect = area_2d.connect("body_entered", self, "bounce")
	
	update_property("color", color)
	update_parts()
	collision_shape.disabled = !enabled or bouncy
	preview_position = custom_preview_position
	if is_preview:
		z_index = 0
		mushroom_cap.z_index = 0
	
	if parts < 0:
		parts = 0

func update_property(key, value):
	if color == Color(1, 0, 0):
		mushroom_cap_color.visible = false
		resizeable_cap_color.visible = false
	else:
		mushroom_cap_color.visible = true
		resizeable_cap_color.visible = true
		mushroom_cap_color.modulate = color
		resizeable_cap_color.modulate = color
	
	if parts > 0:
		resizeable_cap.visible = true
		mushroom_cap.visible = false
		update_parts()
	else:
		if parts < 0: #make sure parts don't go below zero
			parts = 0
		
		mushroom_cap.visible = true
		resizeable_cap.visible = false

func update_parts():
	collision_shape.shape.extents.x = 28 + (16 * parts)
	bounce_area_collision.shape.extents.x = 29 + (16 * parts)
	
	resizeable_cap.rect_size.x = 64 + (32 * parts)
	resizeable_cap_color.rect_size.x = 64 + (32 * parts)
	
	resizeable_cap.rect_position.x = -resizeable_cap.rect_size.x/2
	resizeable_cap_color.rect_position.x = 0
	
	resizeable_cap.rect_pivot_offset.x = resizeable_cap.rect_size.x/2
	resizeable_cap_color.rect_pivot_offset.x = resizeable_cap.rect_size.x/2
	
	visibility_enabler.rect.size.x = 128 + (32 * parts)
	visibility_enabler.rect.position.x = -visibility_enabler.rect.size.x/2

func _input(event):
	if event is InputEventMouseButton and event.is_pressed() and hovered:
		if event.button_index == 5: # Mouse wheel down
			parts -= 1
			if parts < 0:
				parts = 0
			set_property("parts", parts)
		elif event.button_index == 4: # Mouse wheel up
			parts += 1
			set_property("parts", parts)

func _process(delta):
	if !is_equal_approx(spring_anim_power, 0):
		update_bounce_anim(delta)
	else:
		if mushroom_cap.scale != Vector2.ONE:
			mushroom_cap.scale = Vector2.ONE
			
		if $Node2D.scale != Vector2.ONE:
			$Node2D.scale = Vector2.ONE

func _physics_process(delta):
	for object in blacklisted_bodies.keys():
		var cooldown = blacklisted_bodies[object]
		if cooldown > 0:
			cooldown -= delta
			if cooldown <= 0:
				remove_body_to_bounce(object)
			else:
				blacklisted_bodies[object] = cooldown
		
	if bouncy and enabled and mode == 0:
		if area_2d.get_overlapping_bodies().size() > 0:
			for body in area_2d.get_overlapping_bodies():
					bounce(body)


func bounce(body):
	if (body in blacklisted_bodies.keys()) == true:
		return
	
	var normal = transform.y
	
	if "velocity" in body:
		actually_bounce(body)
	elif "velocity" in body.get_parent():
		actually_bounce(body.get_parent())
	
	add_body_to_bounce(body)

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
	animation_player.stop()
	
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
			if y_power < 0 and "prev_is_grounded" in body and body.prev_is_grounded and !body.test_move(body.transform, Vector2(0, 4 * sign(y_power))):
				body.position.y += 4 * sign(y_power)
	animation_player.play("bounce_weak" if is_weak_bounce else "bounce")
	
	if "stamina" in body:
		body.stamina = 100

func add_body_to_bounce(body):
	blacklisted_bodies.get_or_add(body, 0.1)

func remove_body_to_bounce(body):
	blacklisted_bodies.erase(body)

func idle_bounce_anim():
	if is_equal_approx(spring_anim_power, 0):
		animation_player.play("idle")

func set_bounce_anim(power : float):
	spring_anim_power = power

func update_bounce_anim(delta):
	var spring_constant = 500.0
	var damping_constant = 5
	
	var damping_ratio = damping_constant / (2 * sqrt(spring_constant))
	
	var force = (-spring_constant * base_scale_factor) + (damping_constant * spring_anim_power)
	spring_anim_power -= force * delta
	base_scale_factor -= spring_anim_power * delta
	
	mushroom_cap.scale.y = (1 + base_scale_factor*1.25)
	mushroom_cap.scale.x = 1-((mushroom_cap.scale.y-1)/2)
	$Node2D.scale.y = (1 + base_scale_factor*1.25)
	$Node2D.scale.x = 1-(($Node2D.scale.y-1)/2)
