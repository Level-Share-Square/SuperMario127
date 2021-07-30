extends GameObject

onready var sprite = $Sprite
onready var area = $Area2D
onready var static_body = $StaticBody2D
onready var collision_shape = $StaticBody2D/CollisionShape2D
onready var stomp_area = $StompArea
onready var spin_area = $SpinArea
onready var broken_sound = $Broken
onready var break_particle = $BreakParticle
var broken = false

var coins = 0
var time_alive = 0.0
var hue = 0

func _set_properties():
	savable_properties = ["coins"]
	editable_properties = ["coins"]

func _set_property_values(): 
	set_property("coins", coins, true)

func _ready():
	if !enabled:
		collision_shape.disabled = true
		for _area in [area, stomp_area, spin_area]:
			_area.collision_layer = 0
			_area.collision_mask = 0
	elif scale != Vector2.ONE: # Nothing to do on default scale
		# Set inverse scale on the body so its overall scale is identity.
		# For whatever reason, division doesn't work on vectors, soo
		static_body.scale = Vector2(1.0 / scale.x, 1.0 / scale.y)
		# So it doesn't modify all other boxes
		collision_shape.shape = collision_shape.shape.duplicate()
		# Modify the extents by the scale to get the desired collision shape
		collision_shape.shape.extents = Vector2(collision_shape.shape.extents.x * scale.x,\
												collision_shape.shape.extents.y * scale.y)
	
	break_particle.hide()
	sprite.material.set_shader_param("gradient", Singleton.MiscShared.rainbow_gradient_texture)

func is_rainbow(body):
	return body.powerup != null and body.powerup.id == "Rainbow"

func handle_character_exception(character: Character):
	if !is_instance_valid(character): return
	
	if is_rainbow(character):
		static_body.add_collision_exception_with(character)
	else:
		static_body.remove_collision_exception_with(character)

func _physics_process(delta):
	if mode != 1 and enabled:
		time_alive += delta
		
		for hit_body in stomp_area.get_overlapping_bodies():
			if !broken and hit_body.name.begins_with("Character"): if is_rainbow(hit_body):
				broken = true
				if not broken_sound.is_playing(): 
					for i in(coins): create_coin()
					break_particle.show()
					break_particle.set_emitting(true)
					broken_sound.play()
					yield(get_tree().create_timer(3.0), "timeout")
					queue_free() # die
		for hit_body in spin_area.get_overlapping_bodies():
			if !broken and hit_body.name.begins_with("Character"): if is_rainbow(hit_body):
				broken = true
				if not broken_sound.is_playing(): 
					for i in(coins): create_coin()
					break_particle.show()
					break_particle.set_emitting(true)
					broken_sound.play()
					yield(get_tree().create_timer(3.0), "timeout")
					queue_free() # die
		
		var scene : Node = get_tree().current_scene
		if scene.has_node(scene.character):
			handle_character_exception(scene.get_node(scene.character))
		if scene.has_node(scene.character2):
			handle_character_exception(scene.get_node(scene.character2))
		
		if broken:
			sprite.visible = false
			static_body.set_collision_layer_bit(0, false)
			static_body.set_collision_mask_bit(1, false)
			stomp_area.set_collision_layer_bit(0, false)

func create_coin(): #creates a coin
	time_alive += 1
	time_alive += (time_alive/3*5/10)
	var object = LevelObject.new()
	object.type_id = 1
	object.properties = []
	object.properties.append(static_body.global_position)
	object.properties.append(Vector2(1, 1))
	object.properties.append(0)
	object.properties.append(true)
	object.properties.append(true)
	object.properties.append(true)
	var power = int(time_alive*100) % 80
	var velocity_x = -power if int(time_alive * 10) % 2 == 0 else power
	object.properties.append(Vector2(velocity_x, -300)) #makes the coin move around and fly in the air when the block breaks
	get_parent().create_object(object, false) #finishes the object creation
