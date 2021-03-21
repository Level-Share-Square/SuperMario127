extends GameObject

onready var area_shape = $Area2D/CollisionShape2D
onready var sprite = $AnimatedSprite
onready var sprite_1 = $AnimatedSprite/Color1
onready var sprite_2 = $AnimatedSprite/Color2

var retracted_time = 2.5
var burning_time = 2.5
var offset = 0.0
var color = Color(1, 0, 0)

var next_state_timer
var burning = true
var reversed = false

func _set_properties():
	savable_properties = ["retracted_time", "burning_time", "color", "reversed", "offset"]
	editable_properties = ["retracted_time", "burning_time", "color", "reversed", "offset"]

func _set_property_values():
	set_property("retracted_time", retracted_time, true)
	set_property("burning_time", burning_time, true)
	set_property("color", color, true)
	set_property("reversed", reversed, true)
	set_property("offset", offset, true)

func _ready():
	burning = !reversed
	next_state_timer = burning_time if !reversed else retracted_time
	
	next_state_timer += offset

func _physics_process(delta):
	if mode == 1:
		return
	
	if next_state_timer > 0:
		next_state_timer -= delta
		if next_state_timer <= 0:
			next_state_timer = retracted_time if burning else burning_time
			burning = !burning
	
	area_shape.disabled = !burning or !enabled
	
	if burning:
		sprite.position = lerp(sprite.position, Vector2(0, 0), delta * 8)
		sprite.scale = lerp(sprite.scale, Vector2(1, 1), delta * 8)
	else:
		sprite.position = lerp(sprite.position, Vector2(0, 48), delta * 8)
		sprite.scale = lerp(sprite.scale, Vector2(0, 0), delta * 8)

func _process(_delta):
	if color == Color(1, 0, 0):
		sprite.self_modulate = Color(1, 1, 1)
		sprite_1.visible = false
		sprite_2.visible = false
	else:
		var color_0 = color
		var color_1 = color
		
		color_0.s /= 4
		color_1.s /= 2
		
		sprite.self_modulate = color_0
		sprite_1.self_modulate = color_1
		sprite_2.self_modulate = color
		sprite_1.visible = true
		sprite_2.visible = true
