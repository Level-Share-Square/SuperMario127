extends EnemySpawnerBase


export var horn_color: Color = Color.yellow
export var feet_color: Color = Color.green
export var rainbow: bool = false


func get_enemy_properties() -> Array:
	return [
		"horn_color",
		"feet_color",
	]
