extends GameObject

onready var sprite = $Sprite
onready var area = $Area2D
onready var static_body = $StaticBody2D
onready var collision_shape = $StaticBody2D/CollisionShape2D
onready var stomp_area = $StompArea
onready var spin_area = $SpinArea
onready var player_detector = $PlayerStompDetector
onready var player_spin_detector = $PlayerSpinDetector
onready var broken_sound = $Broken
onready var break_particle = $BreakParticle
onready var dust_particle = $DustParticle
var broken = false

var buffer := -5
var character = null

var coins = 0
var delete_timer = 0.0

var time_alive = 0.0

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
	else:
		player_detector.connect("body_entered", self, "detect_player")
	break_particle.hide()
	dust_particle.hide()

func detect_player(body):
	if enabled and body.name.begins_with("Character") and !broken and character == null:
		character = body

func is_metal(body):
	return body.powerup != null and body.powerup.id == 0

func _physics_process(delta):
	if mode != 1 and enabled:
		time_alive += delta
		
		if delete_timer > 0:
			delete_timer -= delta
			if delete_timer <= 0:
				delete_timer = 0
				queue_free()
		
		for hit_body in stomp_area.get_overlapping_bodies():
			if !broken and hit_body.name.begins_with("Character"): if hit_body.velocity.y > 0 and hit_body.big_attack and is_metal(hit_body):
				broken = true
				if not broken_sound.is_playing(): 
					for i in(coins): create_coin()
					break_particle.show()
					dust_particle.show()
					break_particle.set_emitting(true)
					dust_particle.set_emitting(true)
					broken_sound.play()
					delete_timer = 3.0
		for hit_body in spin_area.get_overlapping_bodies():
			if !broken and hit_body.name.begins_with("Character"): if hit_body.attacking and !hit_body.big_attack and is_metal(hit_body):
				broken = true
				if not broken_sound.is_playing(): 
					for i in(coins): create_coin()
					break_particle.show()
					dust_particle.show()
					break_particle.set_emitting(true)
					dust_particle.set_emitting(true)
					broken_sound.play()
					delete_timer = 3.0
		for hit_area in spin_area.get_overlapping_areas():
			if !broken and hit_area.has_method("is_hurt_area") and is_metal(hit_area.get_parent()):
				broken = true
				if not broken_sound.is_playing(): 
					for i in(coins): create_coin()
					break_particle.show()
					dust_particle.show()
					break_particle.set_emitting(true)
					dust_particle.set_emitting(true)
					broken_sound.play()
					delete_timer = 3.0
		
		for hit_body in player_detector.get_overlapping_bodies():
			if hit_body.name.begins_with("Character") and hit_body.velocity.y > 0: 
				if hit_body.big_attack and is_metal(hit_body):
					static_body.add_collision_exception_with(hit_body)
				else:
					static_body.remove_collision_exception_with(hit_body)
		for hit_body in player_spin_detector.get_overlapping_bodies():
			if hit_body.name.begins_with("Character"): 
				if hit_body.attacking and is_metal(hit_body):
					static_body.add_collision_exception_with(hit_body)
				else:
					static_body.remove_collision_exception_with(hit_body)
		
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
