class_name EnemySpawnerBase
extends GameObject


# this is what the game actually places inside the editor, it handles properties
# and enemy spawning in general :>


onready var spawned_enemy: EnemyBase = $Enemy


func _set_properties():
	# if x enabled savable properties append etc etc
	savable_properties = []
	editable_properties = []
	
func _set_property_values():
	# same here
	pass


func _ready():
	# disable it if in editor
	spawned_enemy.enabled = (enabled and mode != 1)
	# give it proper gravity
	spawned_enemy.gravity = Singleton.CurrentLevelData.level_data.areas[Singleton.CurrentLevelData.area].settings.gravity * 2
	# handle being flipped
	if scale.x < 0:
		scale.x = abs(scale.x)
		spawned_enemy.facing_direction = -1
	# and rotation
	if enabled:
		rotation = 0
	
	spawned_enemy.initialize()
	
	# idk why this is needed? but its here
	Singleton.CurrentLevelData.enemies_instanced += 1
