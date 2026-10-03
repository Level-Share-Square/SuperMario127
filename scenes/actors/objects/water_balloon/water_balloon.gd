extends GameObject

onready var sprite = $Sprite
onready var drop = $Sprite/Sprite2
onready var area = $Area2D
onready var refill_sound = $Refill
onready var animation_player = $AnimationPlayer

export var normal_texture : Texture
export var recolorable_texture : Texture 

const BOUNCE_POWER = -400

var added_stamina = 100
var added_water = 50
var collected = false
var respawn_timer = 10.0
var color := Color(0, 0.7, 1)

var timer = 0.0


func _register_properties():
	register_property(4, "added_stamina", added_stamina)
	register_property(5, "added_water", added_water)
	register_property(6, "respawn_timer", respawn_timer)
	register_property(7, "color", color)

func _register_property_info():
	set_property_info("added_stamina", PropertyInfo.new("How much of the F.L.U.D.D's Stamina Wheel is regained upon touching this.", 1, -100, 100, ["", ""], ["", ""], false, "Added Stamina"))
	set_property_info("added_water", PropertyInfo.new("How much % of water is given to the player's F.L.U.D.D. tank upon touching this.\nIf this is 0, the balloon's icon will disappear.", 1, -100, 100, ["", ""], ["", ""], false, "Added Water"))
	set_property_info("respawn_timer", PropertyInfo.new("How many seconds after use this respawns.\nIf set to 0, this won't respawn.", 1, 0, INF, ["", ""], ["", ""], false, "Respawn Timer"))
	set_property_info("color", PropertyInfo.new("The color of this object.", 1, -INF, INF, ["", ""], ["", ""], false, "Color"))


func collect(body):
	if is_enabled_and_on_ground() and !collected and body.name.begins_with("Character") and !body.dead:
		animation_player.play("pop")
		timer = respawn_timer
		body.fuel += added_water
		body.stamina += added_stamina
		if added_water > 0:
			refill_sound.play()
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
	animation_player.play("bpb")
	connect("property_changed", self, "_on_property_changed")
	if is_preview:
		z_index = 0
		sprite.z_index = 0
	if color == Color(0, 0.7, 1):
		sprite.texture = normal_texture
		sprite.self_modulate = Color(1, 1, 1)
	else:
		sprite.texture = recolorable_texture
		sprite.self_modulate = color
		
func _object_ready():
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
			animation_player.play("respawn")
			collected = false
			
func _on_property_changed(key, value):
	if key == "color":
		if color == Color(0, 0.7, 1):
			sprite.texture = normal_texture
			sprite.self_modulate = Color(1, 1, 1)
		else:
			sprite.texture = recolorable_texture
			sprite.self_modulate = value
