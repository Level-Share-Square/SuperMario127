extends GameObject

onready var area = $Area2D
onready var collision_shape = $StaticBody2D/CollisionShape2D

var buffer := -5
var character = null

func _ready():
	preview_position = Vector2(0, 92)
	if mode != 1:
		area.connect("body_entered", self, "enter_area")
		area.connect("body_exited", self, "exit_area")

func enter_area(body):
	if body.name.begins_with("Character"):
		character = body
		
func exit_area(body):
	if body == character:
		character = null
		

func _physics_process(delta):
	if character != null:
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
