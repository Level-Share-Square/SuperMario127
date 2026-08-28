extends EnemySpawnerBase


export var horn_color: Color = Color.yellow
export var feet_color: Color = Color.green
export var rainbow: bool = false


func get_enemy_properties() -> Array:
	return [
		"horn_color",
		"feet_color",
		"rainbow"
	]


func _register_enemy_properties() -> void:
	register_property(9, "horn_color", horn_color)
	register_property(10, "feet_color", feet_color)
	register_property(11, "rainbow", rainbow)


func _ready():
	._ready()
	connect("property_changed", self, "update_property")


func update_property(key: String, value):
	if key == "horn_color":
		for enemy in spawned_enemies:
			enemy.set_horn_color(value)

	if key == "feet_color":
		for enemy in spawned_enemies:
			enemy.set_feet_color(value)
	
	if key == "rainbow":
		for enemy in spawned_enemies:
			enemy.coin_id = 40 if value else 1
			enemy.rainbow = rainbow
		update_property("horn_color", horn_color)
		update_property("feet_color", feet_color)
