tool
extends Sprite


export var begin_rot: float
export var rot_speed: float


func _ready():
	rotation_degrees = begin_rot


func _process(delta):
	rotation_degrees += rot_speed * delta
	rotation_degrees = wrapf(rotation_degrees, -360, 360)
