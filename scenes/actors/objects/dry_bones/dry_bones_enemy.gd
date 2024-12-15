extends EnemyBase


export var is_stationary: bool = false
export var toss_time: float = 5


func _enter_tree():
	cur_state = "IdleState" if is_stationary else "PatrolState"


func set_default_state():
	set_state_by_name("IdleState" if is_stationary else "PatrolState")
