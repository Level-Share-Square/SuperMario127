extends GameObject
class_name BoxBase

const DRAW_DEBUG_RECT: bool = false

export var initial_vel: float = 150.0
export var initial_vel_random: float = 0.3
export var initial_particles: int = 24
export var default_size := Vector2(32, 32)

enum Sides {TOP = 1, BOTTOM = 2, LEFT = 4, RIGHT = 8}

export var top_states: PoolStringArray
export var side_states: PoolStringArray
export var bottom_states: PoolStringArray
export var top_fludds: PoolStringArray
export var side_fludds: PoolStringArray
export var bottom_fludds: PoolStringArray
export var breakable_objects: PoolStringArray
export var required_powerups: PoolStringArray
export var overkill_powerups: PoolStringArray
export var resizable: bool = true

onready var box = $"%Box"
onready var box_collision = $"%BoxCollision"
onready var player_detector = $"%PlayerDetector"
onready var player_collision = $"%PlayerCollision"
onready var break_animation = $"%BreakAnimation"
onready var sprite = $"%Sprite"
onready var break_particles = $"%BreakParticles"

var broken: bool = false
var character: Character
var char_collider: CollisionShape2D
var char_dir_check_collider: CollisionShape2D
var misc_colliders: Array
var last_hit_rect: Rect2
var last_non_intersecting_rect: Rect2

## properties
var coins: int = 0
var size := default_size


func _register_properties(): 
	register_property(4, "coins", coins, true)
	if resizable:
		register_property(5, "size", size, true)


func _register_property_info():
	set_property_info("coins", PropertyInfo.new("How many coins this will drop upon being broken.", 1, 0, INF, ["", ""], ["", ""], true, "Coins"))
	set_property_info("size", PropertyInfo.new("Dimensions of this object", 1, 32, INF, ["X", "Y"], ["", ""], true, "Size"))


func _ready():
	var _connect = connect("property_changed", self, "update_property")
	if not resizable:
		size = default_size
	update_property("size", size)
	if not is_enabled_and_on_ground():
		box.collision_layer = 0


func _physics_process(_delta):
	if DRAW_DEBUG_RECT:
		update()
	try_break()


func update_property(key: String, value):
	if key == "scale":
		# inverse scaling
		player_detector.scale = Vector2.ONE / value
		player_collision.shape = player_collision.shape.duplicate()
		player_collision.shape.extents = (box_collision.shape.extents * value) + Vector2(32, 32)
	
	if key == "size":
		sprite.rect_size = value
		sprite.rect_pivot_offset = sprite.rect_size / 2
		sprite.rect_position = -value / 2
		
		var scale_vector: Vector2 = sprite.rect_size / default_size
		var scale_factor: float = (scale_vector.x + scale_vector.y)/2
		break_particles.process_material = break_particles.process_material.duplicate()
		break_particles.process_material.initial_velocity = initial_vel * clamp(scale_factor / 1.25, 1, INF)
		break_particles.process_material.initial_velocity_random = initial_vel_random * scale_factor
		break_particles.amount = int(float(initial_particles) * scale_factor)
		
		box_collision.shape = box_collision.shape.duplicate()
		box_collision.shape.extents = value / 2
		
		editor_rect.position = -value / 2
		editor_rect.size = value
	
		# inverse scaling
		player_detector.scale = Vector2.ONE / scale
		player_collision.shape = player_collision.shape.duplicate()
		player_collision.shape.extents = (box_collision.shape.extents * scale) + Vector2(32, 32)


func area_entered(area):
	if is_instance_valid(area.owner) and area.owner is Character:
		character = area.owner
		char_collider = area.get_child(0)
		char_dir_check_collider = area.get_child(1)
	elif area.get_parent().name in breakable_objects:
		if area.get_parent() is PhysicsBody2D:
			box.add_collision_exception_with(area.get_parent())
		misc_colliders.append(area.get_child(0))


func area_exited(area):
	if is_instance_valid(area.owner) and area.owner is Character:
		if character in box.get_collision_exceptions():
			character.remove_collision_exception_with(box)
			box.remove_collision_exception_with(character)
		character = null
		char_collider = null
		char_dir_check_collider = null
		# in case there's another overlapping character area still
		for overlapping_area in player_detector.get_overlapping_areas():
			if overlapping_area != area:
				area_entered(overlapping_area)
	else:
		if area.get_parent() is PhysicsBody2D and area.get_parent() in box.get_collision_exceptions():
			box.remove_collision_exception_with(area.get_parent())
		if area.get_child(0) in misc_colliders:
			misc_colliders.erase(area.get_child(0))


func try_break() -> void:
	if not is_enabled_and_on_ground(): return
	if broken: return
	
	var hit_flag: int = 0
	var hit_rect: Rect2
	var compare_hit_rect: Rect2
	var box_rect: Rect2 = rect_from_shape(box_collision)
	
	if is_instance_valid(character) and is_instance_valid(char_collider):
		hit_rect = rect_from_shape(char_collider, true)
		compare_hit_rect = rect_from_shape(char_dir_check_collider, true)
		var hit_dir: int = get_rect_dir(last_hit_rect)
		if char_can_hit(hit_dir, last_hit_rect):
			if not character in box.get_collision_exceptions():
				character.add_collision_exception_with(box)
				box.add_collision_exception_with(character)
			if hit_rect.intersects(box_rect):
				break_box()
				LastInputDevice.rumble(0.5, 0.0, 0.05)
		elif character in box.get_collision_exceptions():
			character.remove_collision_exception_with(box)
			box.remove_collision_exception_with(character)
	
		last_hit_rect = hit_rect
		if not compare_hit_rect.intersects(box_rect):
			last_non_intersecting_rect = compare_hit_rect
	
	if broken: return
	
	for collider in misc_colliders:
		if is_instance_valid(collider):
			hit_rect = rect_from_shape(collider, true)
			if hit_rect.intersects(box_rect):
				break_box()


func get_rect_dir(hit_rect: Rect2) -> int:
	var box_rect: Rect2 = rect_from_shape(box_collision)
	if (hit_rect.position.x + hit_rect.size.x > box_rect.position.x 
	and hit_rect.position.x < box_rect.position.x + box_rect.size.x):
		if hit_rect.position.y + hit_rect.size.y < box_rect.position.y:
			return Sides.TOP
		elif hit_rect.position.y > box_rect.position.y + box_rect.size.y:
			return Sides.BOTTOM
	if hit_rect.position.x + hit_rect.size.x/2 < box_rect.position.x + box_rect.size.x/2:
		return Sides.LEFT
	return Sides.RIGHT


# please breakable box let me hit :pray:
func char_can_hit(char_direction: int, char_rect: Rect2) -> bool:
	if is_instance_valid(character.powerup):
		if not required_powerups.empty() and not character.powerup.name in required_powerups:
			return false
		if character.powerup.name in overkill_powerups: 
			return true 
	elif not required_powerups.empty():
		return false
		
	var has_fludd: bool = is_instance_valid(character.nozzle)
	var has_state: bool = is_instance_valid(character.state)
	if not has_fludd and not has_state: return false
	## hacky but i really don't have another way to do this :(
	if has_state and character.state.name == "SwimmingState" and character.state.boost_time_left <= 0: return false
	
	match char_direction:
		Sides.TOP:
			var fludd_condition: bool = not has_fludd or not (character.nozzle.name in top_fludds and character.nozzle.activated)
			var state_condition: bool = not has_state or not (character.state.name in top_states)
			if state_condition and fludd_condition: return false
			if get_rect_dir(last_non_intersecting_rect) != Sides.TOP: return false
		Sides.LEFT:
			var fludd_condition: bool = not has_fludd or not (character.nozzle.name in side_fludds and character.nozzle.activated)
			var state_condition: bool = not has_state or not (character.state.name in side_states)
			if state_condition and fludd_condition: return false
			if get_rect_dir(last_non_intersecting_rect) != Sides.LEFT: return false
		Sides.RIGHT:
			var fludd_condition: bool = not has_fludd or not (character.nozzle.name in side_fludds and character.nozzle.activated)
			var state_condition: bool = not has_state or not (character.state.name in side_states)
			if state_condition and fludd_condition: return false
			if get_rect_dir(last_non_intersecting_rect) != Sides.RIGHT: return false
		Sides.BOTTOM:
			var fludd_condition: bool = not has_fludd or not (character.nozzle.name in bottom_fludds and character.nozzle.activated)
			var state_condition: bool = not has_state or not (character.state.name in bottom_states)
			if state_condition and fludd_condition: return false
			if get_rect_dir(last_non_intersecting_rect) != Sides.BOTTOM: return false
	return true


func break_box() -> void:
	broken = true
	box_collision.queue_free()
	break_animation.play("break")
	for i in range(coins):
		# the weird algorithms i create to not add randomness to 127 LOL
		var velocity_x: float = ((float(i) - (float(coins)/2)) / float(coins)) * 80
		var velocity_y: float = -150 - (sin(wrapf(float(i) / float(coins) * 2.34, 0, 1)) * 150)
		create_coin(1, box, true, Vector2(velocity_x, velocity_y))


func rect_from_shape(collider: CollisionShape2D, scale_compensation: bool = false) -> Rect2:
	var shape: RectangleShape2D = collider.shape
	var extents: Vector2 = shape.extents
	var old_scale: Vector2 = scale
	scale = Vector2.ONE
	var rect_pos: Vector2 = to_local(collider.global_position)
	scale = old_scale
	
	if scale_compensation:
		rect_pos /= old_scale
		extents /= old_scale
	
	return Rect2(-extents + rect_pos, extents * 2)


func _draw():
	if broken: return
	if not is_instance_valid(char_collider): return
	if not DRAW_DEBUG_RECT: return
	var char_rect: Rect2 = rect_from_shape(char_collider, true)
	var box_rect: Rect2 = rect_from_shape(box_collision)
	draw_rect(char_rect, Color.red)
	draw_rect(box_rect, Color.blue)
