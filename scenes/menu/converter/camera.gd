extends Camera2D


const GP_ZOOM_IN = Vector2(0.025, 0.025)
var old_zoom: Vector2
var disable_gp_zoom: bool = false
var shake_strength: float = 0.0
var shake: bool = false


func _ready():
	old_zoom = zoom


func _physics_process(_delta):
	if !zoom.is_equal_approx(old_zoom):
		zoom = lerp(zoom, old_zoom, 0.08)
	if shake:
		if round(shake_strength) > 0:
			shake_strength = lerp(shake_strength, 0, 0.2)
			offset = _get_random_offset()
		else:
			shake = false


func _get_random_offset() -> Vector2:
	randomize()
	return Vector2(rand_range(-shake_strength, shake_strength), rand_range(-shake_strength, shake_strength))
