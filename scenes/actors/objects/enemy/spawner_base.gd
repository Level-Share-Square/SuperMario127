class_name EnemySpawnerBase
extends GameObject


# this is what the game actually places inside the editor, it handles properties
# and enemy spawning in general :>


enum RespawnMode {Never, Offscreen, Onscreen}

onready var respawn_timer: Timer = $RespawnTimer
onready var visibility_notifier: VisibilityNotifier2D = $VisibilityNotifier2D
var spawned_enemies: Array
# enemies should be made invisible but not the spawner,, cuz of projectiles
var is_visible: bool = true

export var enemy_scene_path: String = "res://scenes/actors/objects/enemy/enemy_base.tscn"

export var respawn_time: float = 15
export(RespawnMode) var respawn_mode
export var max_enemies: int = 1
export var initial_velocity: Vector2
export var spawn_offset: float = 0

var spawner_properties: Array = [
	"respawn_time",
	"respawn_mode",
	"max_enemies",
	"initial_velocity",
	"spawn_offset"
]


func get_enemy_properties() -> Array:
	return []


func set_enemy_property_menus():
	pass


func _set_properties():
	savable_properties = []
	editable_properties = []
	for spawner_property in spawner_properties:
		savable_properties.append(spawner_property)
		editable_properties.append(spawner_property)
	
	# for editable properties, we want to put enemy
	# properties in front of spawner ones, but still in order
	var i: int = 0
	for enemy_property in get_enemy_properties():
		savable_properties.append(enemy_property)
		editable_properties.insert(i, enemy_property)
		i += 1


func _set_property_values():
	for spawner_property in spawner_properties:
		set_property(spawner_property, self[spawner_property], true)
	set_property_menu("respawn_mode", ["option", 3, 0, ['Never', 'Offscreen', 'Onscreen']])
	
	for enemy_property in get_enemy_properties():
		set_property(enemy_property, self[enemy_property], true)
	set_enemy_property_menus()


func instance_enemy(emit_particles: bool = true) -> EnemyBase:
	# idk why this is needed? but its here
	Singleton.CurrentLevelData.enemies_instanced += 1
	
	var spawned_enemy: EnemyBase = load(enemy_scene_path).instance()
	# disable it if in editor
	spawned_enemy.enabled = (enabled and mode != 1)
	# hide it if invisible
	spawned_enemy.visible = is_visible
	# give it proper gravity
	spawned_enemy.gravity = Singleton.CurrentLevelData.level_data.areas[Singleton.CurrentLevelData.area].settings.gravity * 2
	# handle being flipped
	if scale.x < 0:
		spawned_enemy.scale = Vector2.ONE
		spawned_enemy.facing_direction = -1
	# and rotation
	if enabled:
		rotation = 0
	
	spawned_enemy.velocity = initial_velocity
	spawned_enemy.spawn_effect = emit_particles
	for enemy_property in get_enemy_properties():
		spawned_enemy[enemy_property] = self[enemy_property]
	
	spawned_enemies.append(spawned_enemy)
	add_child(spawned_enemy)
	return spawned_enemy


func spawn_enemy():
	var spawned_enemy: EnemyBase = instance_enemy()
	spawned_enemy.connect("tree_exited", self, "enemy_deleted", [spawned_enemy])


func spawn_with_check():
	if spawned_enemies.size() >= max_enemies:
		respawn_timer.start()
		return
	spawn_enemy()


func spawn_onscreen():
	if visibility_notifier.is_on_screen():
		spawn_enemy()
	if spawned_enemies.size() < max_enemies:
		respawn_timer.start()


func enemy_deleted(enemy: EnemyBase):
	spawned_enemies.erase(enemy)
	if respawn_mode == RespawnMode.Onscreen and spawned_enemies.size() < max_enemies:
		respawn_timer.start()


func _ready():
	if mode != 1:
		is_visible = visible
		visible = true
	
	if enabled and mode != 1 and spawn_offset > 0:
		yield(get_tree().create_timer(spawn_offset), "timeout")
	
	var spawned_enemy: EnemyBase = instance_enemy()
	
	if enabled and mode != 1:
		respawn_timer.wait_time = respawn_time
		match respawn_mode:
			RespawnMode.Offscreen:
				visibility_notifier.connect("screen_entered", respawn_timer, "stop")
				visibility_notifier.connect("screen_exited", respawn_timer, "start")
				respawn_timer.connect("timeout", self, "spawn_with_check")
			RespawnMode.Onscreen:
				respawn_timer.connect("timeout", self, "spawn_onscreen")
				if spawned_enemies.size() < max_enemies:
					respawn_timer.start()
	
	# no clue why,, but otherwise it detects the enemy as being "deleted" instantly
	for i in range(5):
		yield(get_tree(), "idle_frame")
	spawned_enemy.connect("tree_exited", self, "enemy_deleted", [spawned_enemy])
