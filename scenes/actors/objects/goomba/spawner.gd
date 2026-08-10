extends EnemySpawnerBase


export var color: Color = Color.red
export var rainbow: bool = false


func get_enemy_properties() -> Array:
	return [
		"color", 
#		"rainbow",
	]
