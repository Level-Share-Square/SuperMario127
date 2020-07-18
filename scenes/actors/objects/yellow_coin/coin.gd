extends GameObject

onready var animated_sprite = $AnimatedSprite
onready var sound = $AudioStreamPlayer
onready var area = $Area2D
onready var shape = $Area2D/CollisionShape2D
onready var visibility_enabler = $VisibilityEnabler2D

export var coins : int = 1

var collected = false
var physics = false
var despawn_timer = 0.0
var gravity : float
var velocity : Vector2

export var anim_fps = 12

func _set_properties():
	savable_properties = ["physics", "velocity"]
	editable_properties = ["physics", "velocity"]

func _set_property_values():
	set_property("physics", physics, true)
	set_property("velocity", velocity, true)

func collect(body):
	if enabled and !collected and body.name.begins_with("Character") and !body.dead:
		CurrentLevelData.level_data.vars.coins_collected += coins
		body.heal()
		var player_id = 1
		if body.name == "Character":
			player_id = 0
		if PlayerSettings.other_player_id == -1 or PlayerSettings.my_player_index == player_id:
			sound.play()
		collected = true
		physics = false
		animated_sprite.animation = "collect"
		animated_sprite.frame = 0
		despawn_timer = 1

func _ready():
	if physics:
		despawn_timer = 10.0
		gravity = CurrentLevelData.level_data.areas[CurrentLevelData.area].settings.gravity
	if !collected:
		orig_f = (OS.get_ticks_msec() * anim_fps / 1000) % 4
		animated_sprite.frame = orig_f
	yield(get_tree().create_timer(0.2), "timeout")
	var _connect = area.connect("body_entered", self, "collect")

# Some nice code here to attempt to synchronize
# coins while still not being laggy
var frame_changed = false
var orig_f = 0
func _process(delta):
	if !frame_changed and !collected:
		var new_f = (OS.get_ticks_msec() * anim_fps / 1000) % 4
		if new_f != orig_f:
			animated_sprite.frame = new_f
			frame_changed = true
	
	if despawn_timer > 0:
		despawn_timer -= delta
		if despawn_timer <= 1:
			visible = !visible
		if despawn_timer <= 0:
			if !sound.playing:
				despawn_timer = 0
				queue_free()
			else:
				despawn_timer = 0.3

func horizontal_cast():
	var pos_new = transform.xform(Vector2(5 if velocity.x > 0 else -5, 0))
	return get_world_2d().direct_space_state.intersect_ray(
		position, pos_new, [self], 17)

func vertical_cast():
	var pos_new = transform.xform(Vector2(0, -10 if velocity.y < 0 else 10))
	return get_world_2d().direct_space_state.intersect_ray(
		position, pos_new, [self], 17)

func _physics_process(delta):
	# Toggle the collection shape (perf)
	var root = get_tree().current_scene
	if root.get_name() == "Player":
		var activate_shape = false
		if !collected:
			if root.has_node(root.character):
				var chr = root.get_node(root.character)
				var new_pos = chr.position
				if (new_pos - position).length_squared() <= 200 + 472.25:
					activate_shape = true
			
			if !activate_shape:
				if root.has_node(root.character2):
					var chr = root.get_node(root.character2)
					var new_pos = chr.position
					if (new_pos - position).length_squared() <= 200 + 472.25:
						activate_shape = true
		
		shape.disabled = !activate_shape
	
	if physics and mode != 1:
		velocity.y += gravity
		position += velocity * delta
		
		var up = velocity.y < 0
		var result = vertical_cast()
		if result:
			if up:
				velocity.y = 30
				position.y += 2
			else:
				velocity.x = lerp(velocity.x, 0, delta)
				velocity.y = 0
				position.y = result.position.y - 10
		
		if abs(velocity.x) > 0.00001:
			result = horizontal_cast()
			if result:
				var x_cast = 5 if velocity.x > 0 else -5
				velocity.x = 0
				position.x = result.position.x - x_cast
