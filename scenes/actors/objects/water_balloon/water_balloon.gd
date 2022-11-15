extends GameObject

onready var sprite = $Sprite
onready var area = $Area2D
onready var sound = $AudioStreamPlayer

var added_stamina = 100
var added_water = 50
var collected = false
var respawn_timer = 0.0
		
		
func _set_properties():
	savable_properties = ["added_stamina", "added_water"]
	editable_properties = ["added_stamina", "added_water"]
	
func _set_property_values():
	set_property("added_stamina", added_stamina)
	set_property("added_water", added_water)

func collect(body):
	if enabled and !collected and body.name.begins_with("Character") and !body.dead:
		$Particles2D.emitting = false
		$Particles2D2.emitting = true
		sound.play()
		sprite.visible = false
		respawn_timer = 40.0
		body.fuel += added_water
		body.stamina += added_stamina
		if body.fuel > 100:
			body.fuel = 100
		if body.stamina > 100:
			body.stamina = 100
		collected = true

func _ready():
	$AnimationPlayer.play("bpb")
	if is_preview:
		z_index = 0
		sprite.z_index = 0
	var _connect = area.connect("body_entered", self, "collect")
	
func _process(delta):
	if respawn_timer > 0:
		respawn_timer -= delta
		if respawn_timer <= 0:
			respawn_timer = 0
			sprite.visible = true
			collected = false
