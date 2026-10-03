extends EnemySpawnerBase


const DEFAULT_COLOR := Color.blue
const DEFAULT_BOOTS_COLOR := Color.red

export var color: Color = DEFAULT_COLOR
export var boots_color: Color = DEFAULT_BOOTS_COLOR
export var rainbow: bool = false
export var squished: bool = false


func get_enemy_properties() -> Array:
	return [
		"color",
		"boots_color",
		"rainbow",
		"squished"
	]


func _ready():
	if(mode == 0):
		connect("property_changed", self, "update_property")
		update_property("rainbow", rainbow)
	else:
		connect("property_changed", self, "editor_update_property")
		editor_update_property("rainbow", rainbow)
		editor_update_property("squished", squished)


func update_property(key: String, value):
	match(key):
		"color":
			for enemy in spawned_enemies:
				enemy.set_color(value)
		"boots_color":
			for enemy in spawned_enemies:
				enemy.set_boots_color(value)
		"rainbow":
			coin_id = 40 if value else 1
			for enemy in spawned_enemies:
				enemy.coin_id = coin_id
				enemy.rainbow = rainbow
			update_property("color", color)
			update_property("boots_color", boots_color)
		"squished":
			for enemy in spawned_enemies:
				enemy.set_squished(value, true)
			
			
func editor_update_property(key: String, value):
	match(key):
		"color":
			enemy_sprite.set_color(value)
		"boots_color":
			enemy_sprite.set_boots_color(value)
		"rainbow":
			enemy_sprite.set_rainbow(rainbow)
			enemy_sprite.set_color(color)
			enemy_sprite.set_boots_color(boots_color)
		"squished":
			enemy_sprite.set_squished(value)
