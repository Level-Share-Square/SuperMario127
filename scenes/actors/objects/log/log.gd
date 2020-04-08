extends GameObject

onready var area = $Area2D
onready var fall_detector = $FallDetector
onready var collision_shape = $StaticBody2D/CollisionShape2D
onready var tween = $Tween
onready var sprite = $Sprite

var buffer := -5
var character = null
var fall_on_touch := true
var falling := false
var shaking := false

var orig_pos : Vector2
var time_falling = 0.0
var time_shaking = 0.0

var shake_amount := 1.0

func _set_properties():
	savable_properties = ["fall_on_touch"]
	editable_properties = ["fall_on_touch"]
	
func _set_property_values():
	set_property("fall_on_touch", fall_on_touch, true)

func _ready():
	orig_pos = position
	if mode != 1:
		var _connect = area.connect("body_entered", self, "enter_area")
		var _connect2 = area.connect("body_exited", self, "exit_area")
		
		var _connect3 = fall_detector.connect("body_entered", self, "fall_detector")
		
func fall_detector(body):
	if character:
		var can_fall = false
		var direction = transform.y.normalized()
		if character.velocity.y > -10 and direction.y > 0:
			can_fall = true
		if character.velocity.y < 10 and direction.y < 0:
			can_fall = true
			
		if body.name.begins_with("Character") and fall_on_touch and !falling and can_fall and !shaking:
			shaking = true
			time_shaking = 0.0

func enter_area(body):
	if body.name.begins_with("Character"):
		character = body
		
func exit_area(body):
	if body == character:
		character = null

func _physics_process(delta):
	if shaking:
		time_shaking += delta
		sprite.offset = Vector2(
			rand_range(-1.0, 1.0) * shake_amount,
			rand_range(-1.0, 1.0) * shake_amount
		)
		if time_shaking > 0.5:
			falling = true
			shaking = false
			sprite.offset = Vector2()
			time_falling = 0.0
			tween.interpolate_property(sprite, "modulate",
			Color(1, 1, 1, 1), Color(1, 1, 1, 0), 2.5,
			Tween.TRANS_QUART, Tween.EASE_IN)
			tween.start()
	if falling:
		position.y += 0.4 + (time_falling * 2)
		$StaticBody2D.constant_linear_velocity.y = 600
		time_falling += delta
		
		if time_falling > 2.5:
			falling = false
			position = orig_pos
			tween.interpolate_property(sprite, "modulate",
			Color(1, 1, 1, 0), Color(1, 1, 1, 1), 0.25,
			Tween.TRANS_QUART, Tween.EASE_OUT)
			tween.start()
		
	if character != null and !falling:
		var direction = transform.y.normalized()
		var line_center = position + (direction * buffer)
		var line_direction = Vector2(-direction.y, direction.x)
		var p1 = line_center + line_direction
		var p2 = line_center - line_direction
		var p = character.position
		var diff = p2 - p1
		var perp = Vector2(-diff.y, diff.x)
		var d = (p - p1).dot(perp)
		
		collision_shape.disabled = sign(d) == 1
		
		if character.velocity.y < -10 and direction.y > 0:
			collision_shape.disabled = true
		if character.velocity.y > 10 and direction.y < 0:
			collision_shape.disabled = true
