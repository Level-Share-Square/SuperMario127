extends GameObject

var steely_nodes = []

var spawn_interval := 7.5
var steely_despawn_timer := 20.0

const STEELY_SPAWN_LIMIT = 16

onready var objects: ObjectManager = get_parent()
onready var spawn_timer: Timer = $SpawnTimer
onready var overlap_checker: Area2D = $OverlapChecker


func _register_properties():
	register_property(4, "spawn_interval", spawn_interval)
	register_property(5, "steely_despawn_timer", steely_despawn_timer)


func _object_ready():
	if is_enabled_and_on_ground():
		spawn_timer.wait_time = spawn_interval
		spawn_timer.start()
		spawn_timer.connect("timeout", self, "_on_spawn_timer_timeout")


func _on_spawn_timer_timeout():
	if overlap_checker.get_overlapping_bodies() and steely_nodes.size() < STEELY_SPAWN_LIMIT and is_enabled_and_on_ground(): 
		var steely_node = create_new_steely_object()
		
		if steely_despawn_timer > 0:
			#needs to be called deffered since the steely isn't even in the tree yet
			steely_node.call_deferred("setup_despawn_timer", steely_despawn_timer) 
		
		steely_node.connect("tree_exited", self, "_remove_steely")
		steely_nodes.append(steely_node)


func create_new_steely_object() -> Node:
	var object := ObjectData.new(ObjectMetadata.new(
		global_position,
		37,
		0
	))

	return get_parent().create_object(object)


func _remove_steely():
	for i in range(steely_nodes.size()):
		if !steely_nodes[i].is_inside_tree():
			steely_nodes.remove(i)
			return
