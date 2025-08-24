class_name AreaMetadata
extends Resource


var bounds: Rect2 = Rect2(0, 0, 80, 30)

var name: String = ""

var sky: int = 1
var background: int = 1
var background_palette: int = 0
var bg_autoscroll_speed: float = 0.0

var gravity: float = 7.82
var timer: float = 0.00

# can hold either the ID for music in the files or a link to custom music
var music = 1
var underwater_music: String = ""


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
