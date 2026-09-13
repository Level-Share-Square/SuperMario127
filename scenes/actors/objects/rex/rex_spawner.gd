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
	._ready()
	connect("property_changed", self, "update_property")
	update_property("rainbow", rainbow)


func update_property(key: String, value):
	if key == "color":
		for enemy in spawned_enemies:
			enemy.set_color(value)

	if key == "boots_color":
		for enemy in spawned_enemies:
			enemy.set_boots_color(value)

	if key == "rainbow":
		coin_id = 40 if value else 1
		for enemy in spawned_enemies:
			enemy.coin_id = coin_id
			enemy.rainbow = rainbow
		update_property("color", color)
		update_property("boots_color", boots_color)

	if key == "squished":
		for enemy in spawned_enemies:
			enemy.set_squished(value, true)
