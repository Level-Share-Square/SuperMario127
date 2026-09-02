extends EnemySpawnerBase


export var color: Color = Color.red
export var rainbow: bool = false


func get_enemy_properties() -> Array:
	return [
		"color", 
#		"rainbow",
	]


func _ready():
	._ready()
	connect("property_changed", self, "update_property")


func update_property(key: String, value):
	if key == "color":
		for enemy in spawned_enemies:
			enemy.set_color(value)
