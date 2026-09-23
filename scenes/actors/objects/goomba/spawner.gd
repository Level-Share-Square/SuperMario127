extends EnemySpawnerBase


export var color: Color = Color.red
export var rainbow: bool = false


func get_enemy_properties() -> Array:
	return [
		"color", 
		"rainbow",
	]


func _ready():
	connect("property_changed", self, "update_property")
	if(mode == 0):
		connect("property_changed", self, "update_property")
		update_property("rainbow", rainbow)
	else:
		connect("property_changed", self, "editor_update_property")
		editor_update_property("rainbow", rainbow)


func update_property(key: String, value):
	if key == "color":
		for enemy in spawned_enemies:
			enemy.set_color(value)

	if key == "rainbow":
		coin_id = 40 if value else 1
		for enemy in spawned_enemies:
			enemy.coin_id = coin_id
			enemy.rainbow = rainbow
		update_property("color", color)
		
		
func editor_update_property(key: String, value):
	match(key):
		"color":
			enemy_sprite.set_color(value)
		"rainbow":
			enemy_sprite.rainbow = value
			editor_update_property("color", color)
