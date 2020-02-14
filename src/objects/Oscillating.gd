extends Sprite

var originalPosition: Vector2;
var time = 0;
export var frequency: int = 1;
export var amplitude: int = 50;

func _ready():
	originalPosition = position;
	texture = load("res://assets/icon.png")

func _process(delta):
	time += delta;
	position.y = (sin(time * frequency) * amplitude) + originalPosition.y
