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
	if(mode == 0):
		connect("property_changed", self, "update_property")
		update_property("rainbow", rainbow)
	else:
		connect("property_changed", self, "editor_update_property")
		editor_update_property("rainbow", rainbow)
	

func editor_update_property(key: String, value):
	match(key):
		"horn_color":
			enemy_sprite.set_horn_color(value)
		"feet_color":
			enemy_sprite.set_feet_color(value)
		"rainbow":
			enemy_sprite.set_rainbow(value)
			enemy_sprite.set_horn_color(horn_color)
			enemy_sprite.set_feet_color(feet_color)

# im not sure why the code was written like this, maybe to support runtime property changing ?
func update_property(key: String, value):
	match(key):
		"horn_color":
			for enemy in spawned_enemies:
				enemy.set_horn_color(value)
		"feet_color":
			for enemy in spawned_enemies:
				enemy.set_feet_color(value)
		"rainbow":
			coin_id = 40 if value else 1
			for enemy in spawned_enemies:
				enemy.coin_id = coin_id
				enemy.set_rainbow(value)
			update_property("horn_color", horn_color)
			update_property("feet_color", feet_color)
