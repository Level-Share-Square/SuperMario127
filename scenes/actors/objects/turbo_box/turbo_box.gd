extends GameObject

onready var area = $Area2D
onready var detector = $StompDetector
onready var collision_shape = $StompDetector/CollisionShape2D
onready var sprite = $Sprite
onready var sound = $AudioStreamPlayer

var buffer := -5
var character = null

var respawn_timer = 0.0

func _ready():
	rotation_degrees = 0
	if mode != 1:
		var _connect = area.connect("body_entered", self, "enter_area")
		var _connect2 = area.connect("body_exited", self, "exit_area")
		
		var _connect3 = detector.connect("body_entered", self, "enter_detector")

func enter_area(body):
	if body.name.begins_with("Character"):
		character = body
		
func exit_area(body):
	if body == character:
		character = null
		
# warning-ignore: unused_argument
func enter_detector(body):
	if body.name.begins_with("Character") and respawn_timer == 0 and enabled and body.velocity.y > 0:
		respawn_timer = 10.0
		if body.state != body.get_state_node("GroundPoundState"):
			body.velocity.y = -230
			body.position.y -= 4
			if body.state != null and body.state.name != "DiveState":
				body.set_state_by_name("BounceState", 0)
		body.add_nozzle("TurboNozzle")
		sprite.visible = false
		sound.play()
		
		var object = LevelObject.new()
		object.type_id = 20
		object.properties = []
		object.properties.append(position + Vector2(0, 4))
		object.properties.append(Vector2(1, 1))
		object.properties.append(0)
		object.properties.append(true)
		object.properties.append(true)
		object.properties.append(Vector2(0, -50))
		object.properties.append("TurboNozzle")
		get_parent().create_object(object, false)
		
func _physics_process(delta):
	if respawn_timer > 0:
		respawn_timer -= delta
		if respawn_timer <= 0:
			respawn_timer = 0
			sprite.visible = true

func _process(_delta):
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
		
		if character.velocity.y < -10 and direction.y > 0.5:
			collision_shape.disabled = true
		if character.velocity.y > 10 and direction.y < -0.5:
			collision_shape.disabled = true
