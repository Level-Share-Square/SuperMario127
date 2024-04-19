extends GameObject

onready var sprite = $Sprite
onready var drop = $Sprite/Sprite2
onready var area = $Area2D
onready var sound = $AudioStreamPlayer

export var normal_texture : Texture
export var recolorable_texture : Texture 

const BOUNCE_POWER = -400

var added_stamina = 100
var added_water = 50
var collected = false
var respawn_timer = 10.0
var color := Color(0, 0.7, 1)

var timer = 0.0

		
		
func _set_properties():
	savable_properties = ["added_stamina", "added_water", "respawn_timer", "color"]
	editable_properties = ["added_stamina", "added_water", "respawn_timer", "color"]
	
func _set_property_values():
	set_property("added_stamina", added_stamina)
	set_property("added_water", added_water)
	set_property("respawn_timer", respawn_timer)
	set_property("color", color)

func collect(body):
	if enabled and !collected and body.name.begins_with("Character") and !body.dead:
		$Particles2D.emitting = false
		$Particles2D2.emitting = true
		sound.play()
		sprite.visible = false
		timer = respawn_timer
		body.fuel += added_water
		body.stamina += added_stamina
		if body.fuel > 100:
			body.fuel = 100
		if body.stamina > 100:
			body.stamina = 100
		collected = true
		#bounce
		if !body.big_attack and !body.invincible and body.velocity.y > -325:
			body.set_state_by_name("BounceState", 0)
			body.velocity.y = BOUNCE_POWER

func _ready():
	$AnimationPlayer.play("bpb")
	connect("property_changed", self, "_on_property_changed")
	if is_preview:
		z_index = 0
		sprite.z_index = 0
	var _connect = area.connect("body_entered", self, "collect")
	if color == Color(0, 0.7, 1):
		sprite.texture = normal_texture
		sprite.self_modulate = Color(1, 1, 1)
	else:
		sprite.texture = recolorable_texture
		sprite.self_modulate = color
	
func _process(delta):
	if added_water == 0:
		drop.visible = false
		$Particles2D.emitting = false
	else:
		drop.visible = true
	if timer > 0:
		timer -= delta
		if timer <= 0:
			timer = 0
			sprite.visible = true
			$Particles2D.emitting = true
			collected = false
			
func _on_property_changed(key, value):
	if key == "color":
		if color == Color(0, 0.7, 1):
			sprite.texture = normal_texture
			sprite.self_modulate = Color(1, 1, 1)
		else:
			sprite.texture = recolorable_texture
			sprite.self_modulate = value
