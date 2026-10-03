extends PlayerDetector


onready var enemy: EnemyBase = get_owner()


func _physics_process(_delta):
	position.x = abs(position.x) * enemy.facing_direction
