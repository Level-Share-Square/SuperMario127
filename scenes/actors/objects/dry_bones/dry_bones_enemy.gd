extends EnemyBase


export var is_stationary: bool = false


func _ready():
	cur_state = "IdleState" if is_stationary else "PatrolState"


func set_default_state():
	set_state_by_name("IdleState" if is_stationary else "PatrolState")
