extends GameObject

onready var area = $Area2D
onready var area_shape = $Area2D/CollisionShape2D
onready var sprite = $Sprite
onready var current_scene = get_tree().get_current_scene()

var shine_tag: String = "shine_tag"
var time_limit: float = 0.0
var one_shot: bool = false
var parts: int = 1

var one_shot_run: bool = false
var timer : TimerBase
var timer_manager : TimerManager


func _set_properties():
	savable_properties = ["shine_tag", "time_limit", "one_shot", "parts"]
	editable_properties = ["shine_tag", "time_limit", "one_shot", "parts"]


func _set_property_values():
	set_property("shine_tag", shine_tag)
	set_property("time_limit", time_limit)
	set_property("one_shot", one_shot)
	set_property("parts", parts)


func _input(event):
	parts_input_handler(event,self)


func update_property(_key, _value):
	update_parts()


func update_parts():
	if parts <= 0:
		parts = 1
		set_property("parts", parts, true)
	
	sprite.rect_size.y = parts * 32
	sprite.rect_position.y = (-16 * parts)
	area_shape.shape.extents.y = 16 * parts


func _ready():
	if mode != 1:
		var _connect = area.connect("body_entered", self, "_body_entered")
		sprite.visible = false
		timer_manager = current_scene.get_timer_manager()
	else:
		connect("property_changed", self, "update_property")
	
	if parts < 1:
		parts = 1
	
	update_parts()


func _process(delta):
	if parts <= 0:
		parts = 1
		set_property("parts", parts, true)


func _body_entered(body):
	if mode == 1:
		return
	
	var shines = get_tree().get_nodes_in_group("tag_shine_%s" % shine_tag.to_lower())
	shines = remove_active_shines(shines)
	
	if enabled and body is Character:
		if time_limit <= 0:
			if shines.size() <= 0:
				return
			
			activate_shines(shines, false)
		else:
			if is_instance_valid(timer) or shines.size() <= 0:
				return
			
			var camera = current_scene.get_node(current_scene.camera)
			
			yield(activate_shines(shines, true), "completed")
			
			while camera.in_cutscene:
				yield(get_tree(), "idle_frame")
			
			for shine in shines:
				shine.pause_mode = PAUSE_MODE_INHERIT
			
			timer = timer_manager.add_set_timer("shine_%s" % shine_tag, time_limit, "switch", false, true)
			timer.connect("time_over", self, "deactivate_shines", [shines])


func activate_shines(shines: Array, timed: bool = false):
	get_tree().set_group("tag_shine_%s" % shine_tag.to_lower(), "pause_mode", PAUSE_MODE_PROCESS)
	var camera = current_scene.get_node(current_scene.camera)
	
	for shine in shines:
		shine.activate_shine(0 if !timed else 2, true)
		
		if timed:
			shine.connect("shine_collected", timer_manager, "pause_resume_timer", ["shine_%s" % shine_tag, true])
			shine.connect("shine_dance_end", timer_manager, "pause_resume_timer", ["shine_%s" % shine_tag, false])
	
	yield(get_tree(), "idle_frame")
	
	camera.call_deferred("start_queue")


func deactivate_shines(shines: Array):
	for shine in shines:
		shine.deactivate_shine(true)


func remove_active_shines(tagged_shines: Array) -> Array:
	for shine in tagged_shines:
		if shine.activated and !shine.collected:
			tagged_shines.remove(tagged_shines.find(shine))
	
	return tagged_shines
