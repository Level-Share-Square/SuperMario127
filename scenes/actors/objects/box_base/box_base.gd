extends GameObject
class_name BoxBase

const INITIAL_VEL: float = 150.0
const DEFAULT_SIZE := Vector2(32, 32)
const DRAW_DEBUG_RECT: bool = false

enum Sides {TOP = 1, BOTTOM = 2, LEFT = 4, RIGHT = 8}

export(int, FLAGS, "Top", "Bottom", "Left", "Right") var breakable_sides = 15
export var top_states: PoolStringArray
export var side_states: PoolStringArray
export var bottom_states: PoolStringArray
export var breakable_objects: PoolStringArray
export var required_powerups: PoolStringArray
export var overkill_powerups: PoolStringArray
export var resizable: bool = true

onready var box = $"%Box"
onready var box_collision = $"%BoxCollision"
onready var editor_collision = $"%EditorCollision"
onready var player_detector = $"%PlayerDetector"
onready var player_collision = $"%PlayerCollision"
onready var break_animation = $"%BreakAnimation"
onready var sprite = $"%Sprite"
onready var break_particles = $"%BreakParticles"

var broken: bool = false
var character: Character
var char_collider: CollisionShape2D
var misc_colliders: Array
var last_hit_rect: Rect2
var last_non_intersecting_rect: Rect2

## properties
var coins: int = 0
var size := DEFAULT_SIZE


func _register_properties(): 
	register_property(4, "coins", coins, true)
	if resizable:
		register_property(5, "size", size, true)


func _register_property_info():
	set_property_info("coins", PropertyInfo.new("How many coins this will drop upon being broken.", 1, 0, INF, ["", ""], ["", ""], true, "Coins"))
	set_property_info("size", PropertyInfo.new("Dimensions of this object", 1, 32, INF, ["X", "Y"], ["", ""], true, "Size"))


func _ready():
	var _connect = connect("property_changed", self, "update_property")
	if resizable:
		update_property("size", size)


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
		
		var scale_factor: Vector2 = sprite.rect_size / DEFAULT_SIZE
		break_particles.process_material = break_particles.process_material.duplicate()
		break_particles.process_material.initial_velocity = INITIAL_VEL * (scale_factor.x + scale_factor.y)/2
		
		box_collision.shape = box_collision.shape.duplicate()
		editor_collision.shape = box_collision.shape
		box_collision.shape.extents = value / 2
	
		# inverse scaling
		player_detector.scale = Vector2.ONE / scale
		player_collision.shape = player_collision.shape.duplicate()
		player_collision.shape.extents = (box_collision.shape.extents * scale) + Vector2(32, 32)


func area_entered(area):
	if is_instance_valid(area.owner) and area.owner is Character:
		if not is_instance_valid(char_collider) or char_collider.get_parent().name.find("Spin") == -1:
			character = area.owner
			char_collider = area.get_child(0)
	else:
		if area.get_parent() is PhysicsBody2D:
			box.add_collision_exception_with(area.get_parent())
		misc_colliders.append(area.get_child(0))


func area_exited(area):
	if is_instance_valid(area.owner) and area.owner is Character:
		if character in box.get_collision_exceptions():
			box.remove_collision_exception_with(character)
		character = null
		char_collider = null
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
	if broken: return
	
	var hit_flag: int = 0
	var hit_rect: Rect2
	var box_rect: Rect2 = rect_from_shape(box_collision)
	
	if is_instance_valid(character) and is_instance_valid(char_collider):
		hit_rect = rect_from_shape(char_collider, true)
		var hit_dir: int = get_rect_dir(last_hit_rect)
		if char_can_hit(hit_dir, last_hit_rect):
			if not character in box.get_collision_exceptions():
				box.add_collision_exception_with(character)
			if hit_rect.intersects(box_rect):
				break_box()
		elif character in box.get_collision_exceptions():
			box.remove_collision_exception_with(character)
	
	last_hit_rect = hit_rect
	if not last_hit_rect.intersects(box_rect):
		last_non_intersecting_rect = last_hit_rect
	
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
	if not is_instance_valid(character.state): return false
	## hacky but i really don't have another way to do this :(
	if character.state.name == "SwimmingState" and character.state.boost_time_left <= 0: return false
	
	match char_direction:
		Sides.TOP:
			if not character.state.name in top_states: return false
			if get_rect_dir(last_non_intersecting_rect) != Sides.TOP: return false
		Sides.LEFT:
			if not character.state.name in side_states: return false
			if get_rect_dir(last_non_intersecting_rect) != Sides.LEFT: return false
		Sides.RIGHT:
			if not character.state.name in side_states: return false
			if get_rect_dir(last_non_intersecting_rect) != Sides.RIGHT: return false
		Sides.BOTTOM:
			if not character.state.name in bottom_states: return false
			if get_rect_dir(last_non_intersecting_rect) != Sides.BOTTOM: return false
	return true


func break_box() -> void:
	broken = true
	box_collision.queue_free()
	break_animation.play("break")
	for i in range(coins):
		var velocity_x: float = -80 if i % 2 == 0 else 80
		create_coin(1, box, true, Vector2(velocity_x, -300))


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
