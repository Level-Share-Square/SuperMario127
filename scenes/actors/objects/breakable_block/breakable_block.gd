extends GameObject

onready var sprite = $Sprite
onready var area = $Area2D
onready var body = $StaticBody2D
onready var collision_shape = $StaticBody2D/CollisionShape2D
onready var stomp_area = $StompArea
onready var player_detector = $PlayerDetector
onready var broken_sound = $Broken
onready var break_particle = $BreakParticle
onready var dust_particle = $DustParticle
var broken = false

var buffer := -5
var character = null

var coins = 0

func _set_properties():
	savable_properties = ["coins"]
	editable_properties = ["coins"]

func _set_property_values(): set_property("coins", coins, true)

func _ready(): 
	randomize()
	player_detector.connect("body_entered", self, "detect_player")
	break_particle.hide()
	dust_particle.hide()

func detect_player(body):
	if enabled and body.name.begins_with("Character") and !broken and character == null:
		character = body

func _physics_process(delta):
	if mode != 1: 
		for hit_body in stomp_area.get_overlapping_bodies():
			if hit_body.name.begins_with("Character"): if hit_body.velocity.y > 0: if character.big_attack or character.attacking:
				broken = true
				if not broken_sound.is_playing(): 
					for i in(coins): create_coin()
					break_particle.show()
					dust_particle.show()
					break_particle.set_emitting(true)
					dust_particle.set_emitting(true)
					broken_sound.play()
				yield($Broken, "finished") 
				broken()
		for hit_body in player_detector.get_overlapping_bodies():
			if hit_body.name.begins_with("Character"): if hit_body.velocity.y > 0: 
				if character.big_attack:
					body.set_collision_layer_bit(0, false)
					body.set_collision_mask_bit(1, false)
				else:
					body.set_collision_layer_bit(0, true)
					body.set_collision_mask_bit(1, true)
		
		if broken == true:
			sprite.visible = false
			body.set_collision_layer_bit(0, false)
			body.set_collision_mask_bit(1, false)
			stomp_area.set_collision_layer_bit(0, false)

func broken():
	queue_free() #end

func create_coin(): #creates a coin
	var object = LevelObject.new() #makes an object variable
	object.type_id = 1 #assigns it as a coin
	object.properties = [body.global_position, Vector2(1, 1), 0, false, true, true] #assigns the properties
	var velocity_x = randi() % 160 #makes the coin randomly disperse around the map
	velocity_x -= 80 #allows the coins to disperse leftwards
	object.properties.append(Vector2(velocity_x, -300)) #makes the coin move around and fly in the air when the block breaks
	get_parent().create_object(object, false) #finishes the object creation
