extends EnemySpawnerBase


export var color: Color = Color.red
export var rainbow: bool = false


func get_enemy_properties() -> Array:
	return [
		"color", 
#		"rainbow",
	]


func _register_enemy_properties() -> void:
	register_property(9, "color", color)
#	register_property(10, "rainbow", rainbow)
