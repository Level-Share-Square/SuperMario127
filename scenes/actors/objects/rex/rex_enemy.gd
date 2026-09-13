extends EnemyBase


const DEFAULT_COLOR := Color.darkslateblue

export var color : Color = DEFAULT_COLOR

# if the rex is squished or not
export var squished = false setget set_squished

export var unsquished_frames: SpriteFrames
export var squished_frames: SpriteFrames
export var unsquished_size = Vector2(20, 30)
export var squished_size = Vector2(20, 16)
export var unsquished_windup_length = 0.1
export var squished_windup_length = 0.15
export var unsquished_spring_depth = 22
export var squished_spring_depth = 12
export var unsquished_pause_length = 0.05
export var squished_pause_length = 0.2

var rainbow: bool = false setget set_rainbow 
var rainbow_color := Color(0.999, 0, 0) # so that it doesn't ever snap to the default color

# stores the last state before being squished
var last_state: EnemyState

onready var unsquished_colliders: Array = [$Damage/Stomp/CollisionShape2D, $Damage/Attack/CollisionShape2D] 
onready var squished_colliders: Array = [$Damage/Stomp/Squished, $Damage/Attack/Squished]

onready var player_detector: Area2D = $PlayerDetector
onready var player_forgetter: Area2D = $PlayerForgetter
onready var anger_particles: CPUParticles2D = $"%AngerParticles"


func _ready():
	._ready()
	set_squished(squished, true)


func _physics_process(delta):
	pass
	#$"%StompCloud".direction.x = -1 if facing_direction > 0 else 1

func set_rainbow(value: bool) -> void:
	rainbow = value
	if is_instance_valid(damage):
		damage.bounce_type = EnemyDamage.BounceType.NORMAL if value else EnemyDamage.BounceType.SPRING

func set_squished(value, set_frames: bool = false) -> void:
	squished = value
	enemy_size = unsquished_size if !squished else squished_size
	if is_instance_valid(anger_particles):
		anger_particles.emitting = squished and enabled
	if set_frames and is_instance_valid(sprite):
		sprite.frames = squished_frames if squished else unsquished_frames
	
	if not unsquished_colliders or not squished_colliders:
		return
	for collider in unsquished_colliders:
		collider.disabled = squished
	for collider in squished_colliders:
		collider.disabled = !squished
	if not rainbow and is_instance_valid(damage):
		damage.spring_bounce_windup_length = unsquished_windup_length if not squished else squished_windup_length
		damage.spring_bounce_depth = unsquished_spring_depth if not squished else squished_spring_depth
		damage.spring_bounce_pause_length = unsquished_pause_length if not squished else squished_pause_length
		
