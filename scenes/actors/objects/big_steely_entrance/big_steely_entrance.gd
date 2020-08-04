extends GameObject

var steely_nodes = []

var spawn_interval = 7.5
var steely_despawn_timer = 20

const STEELY_SPAWN_LIMIT = 16

onready var objects = get_parent()
onready var spawn_timer = $SpawnTimer

func _set_properties():
	savable_properties = ["spawn_interval", "steely_despawn_timer"]
	editable_properties = ["spawn_interval", "steely_despawn_timer"]
	
func _set_property_values():
	set_property("spawn_interval", spawn_interval, 1)
	set_property("steely_despawn_timer", steely_despawn_timer)

func _ready():
	if mode == 0: # if in play mode
		spawn_timer.wait_time = spawn_interval
		spawn_timer.start()
		spawn_timer.connect("timeout", self, "_on_spawn_timer_timeout")

func _on_spawn_timer_timeout():
	var no_steelies_in_front = check_for_blocking_elements()

	if no_steelies_in_front and steely_nodes.size() < STEELY_SPAWN_LIMIT: 
		var steely_node = create_new_steely_object()

		if steely_despawn_timer > 0:
			#needs to be called deffered since the steely isn't even in the tree yet
			steely_node.call_deferred("setup_despawn_timer", steely_despawn_timer) 
		
		steely_node.connect("tree_exited", self, "_remove_steely")
		steely_nodes.append(steely_node)

func check_for_blocking_elements() -> bool:
	#use the collision shape to query the space state to check for collisions with steelies, if there's any steelies in the way don't spawn a new one
	var shape_query_parameters = Physics2DShapeQueryParameters.new()
	shape_query_parameters.set_shape($CollisionShape2D.shape)
	shape_query_parameters.transform = transform
	shape_query_parameters.collision_layer = 1 + 2 + 32 #layers for terrain, players, and big steelies
	return get_world_2d().direct_space_state.intersect_shape(shape_query_parameters).empty()

func create_new_steely_object() -> Node:
	var object = LevelObject.new()
	object.type_id = 37
	object.properties = []
	object.properties.append(global_position)
	object.properties.append(scale)
	object.properties.append(0)
	object.properties.append(true)
	object.properties.append(true)

	return objects.create_object(object, false)

func _remove_steely():
	for i in range(steely_nodes.size()):
		if !steely_nodes[i].is_inside_tree():
			steely_nodes.remove(i)
			return
