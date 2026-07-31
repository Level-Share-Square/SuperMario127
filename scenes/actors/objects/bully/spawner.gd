extends EnemySpawnerBase


export var horn_color: Color = Color.yellow
export var feet_color: Color = Color.green
export var rainbow: bool = false


func get_enemy_properties() -> Array:
	return [
		"horn_color",
		"feet_color",
	]


func _register_enemy_properties() -> void:
	register_property(9, "horn_color", horn_color)
	register_property(10, "feet_color", feet_color)
	register_property(11, "rainbow", rainbow)
