extends GameObject

onready var sprite = $Sprite
onready var area = $Area2D
onready var static_body = $StaticBody2D
onready var collision_shape = $StaticBody2D/CollisionShape2D
onready var stomp_area = $StompArea
onready var spin_area = $SpinArea
onready var turbo_spin_area = $TurboSpinArea
onready var player_detector = $PlayerStompDetector
onready var player_spin_detector = $PlayerSpinDetector
onready var break_detector = $BreakDetector
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

func _set_property_values(): set_property("coins", coins, true)

func _ready():
	player_detector.connect("body_entered", self, "detect_player")
	break_particle.hide()
	dust_particle.hide()
	
#warning-ignore:unused_argument
func exploded(hit_pos):
	if !broken:
		break_box()

#warning-ignore:unused_argument
func steely_hit(hit_pos):
	if !broken:
		break_box()

func break_box():
	broken = true
	if not broken_sound.is_playing(): 
		break_detector.set_collision_layer_bit(2, false)
		for i in(coins): create_coin()
		break_particle.show()
		dust_particle.show()
		break_particle.set_emitting(true)
		dust_particle.set_emitting(true)
		broken_sound.play()
		delete_timer = 3.0

func detect_player(body):
	if enabled and body.name.begins_with("Character") and !broken and character == null:
		character = body

func top_breakable(hit_body):
	return hit_body.name.begins_with("Character") and (hit_body.velocity.y > 0 and !hit_body.is_grounded()) and (hit_body.big_attack or hit_body.invincible)

func side_breakable(hit_body):
	return hit_body.name.begins_with("Character") and ((hit_body.attacking and !hit_body.big_attack and !hit_body.turbo_nerf) or hit_body.invincible)

func turbo_breakable(hit_body):
	return hit_body.name.begins_with("Character") and (hit_body.using_turbo and !hit_body.turbo_nerf)

func _physics_process(delta):
	if mode != 1: 
		time_alive += delta
		
		if delete_timer > 0:
			delete_timer -= delta
			if delete_timer <= 0:
				delete_timer = 0
				queue_free()
		
		for hit_body in stomp_area.get_overlapping_bodies():
			if !broken and top_breakable(hit_body):
				break_box()
		for hit_body in spin_area.get_overlapping_bodies():
			if !broken and side_breakable(hit_body):
				break_box()
		for hit_body in turbo_spin_area.get_overlapping_bodies():
			if !broken and turbo_breakable(hit_body):
				break_box()
		
		if broken == true:
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
