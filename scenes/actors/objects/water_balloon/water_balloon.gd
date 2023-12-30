extends GameObject

onready var sprite = $Sprite
onready var drop = $Sprite/Sprite2
onready var area = $Area2D
onready var sound = $AudioStreamPlayer

var added_stamina = 100
var added_water = 50
var collected = false
var respawn_timer = 10.0

var timer = 0.0

		
		
func _set_properties():
	savable_properties = ["added_stamina", "added_water", "respawn_timer"]
	editable_properties = ["added_stamina", "added_water", "respawn_timer"]
	
func _set_property_values():
	set_property("added_stamina", added_stamina)
	set_property("added_water", added_water)
	set_property("respawn_timer", respawn_timer)

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
		if !body.big_attack and !body.invincible and body.velocity.y > -325:
			body.velocity.y = -325

func _ready():
	$AnimationPlayer.play("bpb")
	if is_preview:
		z_index = 0
		sprite.z_index = 0
	var _connect = area.connect("body_entered", self, "collect")
	
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
