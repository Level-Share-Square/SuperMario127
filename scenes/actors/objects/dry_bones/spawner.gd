extends EnemySpawnerBase


export var is_stationary: bool = false
export var toss_time: float = 5

func get_enemy_properties() -> Array:
	return [
		"is_stationary",
		"toss_time"
	]
