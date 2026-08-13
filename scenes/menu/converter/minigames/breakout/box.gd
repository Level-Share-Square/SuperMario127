extends StaticBody2D


const COLORS = [
	Color(1, 0.5, 0.5),
	Color(1, 1, 0.5),
	Color(0.5, 1, 0.5),
	Color(0.5, 0.5, 1),
	Color(1, 0.5, 1),
	Color.white
]

onready var sprite = $Sprite
onready var impact = $Impact
onready var hit = $Hit
onready var hit_break = $HitBreak
onready var color_index: int = sprite.region_rect.position.y / 24

const MAX_HP: int = 350
var hp: int = MAX_HP

var shake_strength: float = 0.0
var shake: bool = false

signal award_points(amount, color)

func _ready():
	sprite.material = sprite.material.duplicate()


func hit(fireball: KinematicBody2D) -> void:
	var damage: int = min(fireball.velocity.length(), hp)
	hp -= damage
	emit_signal("award_points", damage, COLORS[color_index])
	
	sprite.material.set_shader_param("opacity", clamp(float(hp) / float(MAX_HP), 0.0, 1.0))
	if hp <= 0:
		sprite.hide()
		impact.show()
		hit_break.play()
		collision_layer = 0
		
		var impact_color: Color = COLORS[color_index]
		impact_color.r = 5 if impact_color.r > 0.5 else 0
		impact_color.g = 5 if impact_color.g > 0.5 else 0
		impact_color.b = 5 if impact_color.b > 0.5 else 0
		impact_color.a = 0
		
		var tween: SceneTreeTween = create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_QUAD)
		tween.tween_property(impact, "modulate", impact_color, 0.5)
		tween.tween_callback(self, "queue_free")
	else:
		shake = true
		shake_strength = 4.0
		hit.play()


func _physics_process(_delta):
	if shake:
		if round(shake_strength) > 0:
			shake_strength = lerp(shake_strength, 0, 0.2)
			sprite.offset = _get_random_offset()
		else:
			sprite.offset = Vector2.ZERO
			shake = false


func _get_random_offset() -> Vector2:
	return Vector2(rand_range(-shake_strength, shake_strength), rand_range(-shake_strength, shake_strength))
