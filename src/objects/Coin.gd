extends Sprite

signal on_collect
onready var area := Area2D.new()
onready var shape := CollisionShape2D.new()
onready var sound := AudioStreamPlayer.new()

var collected = false
var destroyTimer = 0.0

func destroy():
	queue_free()

func collect(body):
	if !collected:
		sound.play()
		collected = true;
		emit_signal("on_collect")
		destroyTimer = 2

func _ready():
	texture = load("res://assets/textures/items/coins/yellow.png")
	shape.shape = RectangleShape2D.new()
	shape.scale = Vector2(1.5, 1.5)
	area.connect("body_entered", self, "collect")
	area.add_child(shape)
	add_child(area)
	var stream = load("res://assets/sounds/coin.wav")
	sound.stream = stream
	sound.volume_db = 5;
	add_child(sound)
	
func _physics_process(delta):
	if destroyTimer > 0:
		destroyTimer -= delta
		if self.scale.x > 0:
			self.scale -= Vector2(0.1, 0.1)
		else:
			self.scale = Vector2(0, 0)
			self.visible = false;
		if destroyTimer <= 0:
			destroyTimer = 0
			destroy()
