extends EnemyBase


const DEFAULT_COLOR := Color.darkslateblue

export var color : Color = DEFAULT_COLOR

# if the rex is squished or not
export var squished = false setget set_squished

export var unsquished_size = Vector2(20, 30)
export var squished_size = Vector2(20, 16)
export var unsquished_spring_depth = 22
export var squished_spring_depth = 12

var rainbow: bool = false setget set_rainbow 
var rainbow_color := Color(0.999, 0, 0) # so that it doesn't ever snap to the default color

# stores the last state before being squished
var last_state: EnemyState

onready var unsquished_colliders: Array = [$Damage/Stomp/CollisionShape2D, $Damage/Attack/CollisionShape2D] 
onready var squished_colliders: Array = [$Damage/Stomp/Squished, $Damage/Attack/Squished]

onready var player_detector: Area2D = $PlayerDetector

func _ready():
	._ready()
	set_squished(squished)


func _physics_process(delta):
	._physics_process(delta)

func set_rainbow(value: bool) -> void:
	rainbow = value
	if is_instance_valid(damage):
		damage.bounce_type = EnemyDamage.BounceType.NORMAL if value else EnemyDamage.BounceType.SPRING

func set_squished(value) -> void:
	squished = value
	enemy_size = unsquished_size if !squished else squished_size
	if not unsquished_colliders or not squished_colliders:
		return
	for collider in unsquished_colliders:
		collider.disabled = squished
	for collider in squished_colliders:
		collider.disabled = !squished
	if not rainbow and is_instance_valid(damage):
		damage.spring_bounce_depth = unsquished_spring_depth if not squished else squished_spring_depth
