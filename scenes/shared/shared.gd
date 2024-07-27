extends LevelDataLoader

export var tilemaps : NodePath
export var objects : NodePath
export var boo_block_texture = "res://assets/tiles/boo_block/boo_block.png"
export var boo_block_texture_invis = "res://assets/tiles/boo_block/boo_block_invis.png"

onready var loaded_boo_texture = load(boo_block_texture)
onready var loaded_boo_texture_invis = load(boo_block_texture_invis)

onready var tilemaps_node = get_node(tilemaps)
onready var objects_node = get_node(objects)

func _ready():
	var tex = loaded_boo_texture
	if get_tree().get_current_scene().mode == 0:
		tex = loaded_boo_texture_invis
	tilemaps_node.middle_tilemap_node.tile_set.tile_set_texture(18, tex)
	Singleton.ActionManager.shared_node = self
	#yield(self, "loaded")
	#terrain_generator.generate(randi(), self)

func get_objects_node():
	return objects_node

func set_tile(x: int, y:int, layer: int, tileset_id: int, tile_id: int, palette_id : int = 0):
	#print("set ",x," ",y)
	tilemaps_node.set_tile(x, y, layer, tileset_id, tile_id, palette_id)

func get_tile(x: int, y:int, layer: int):
	return tilemaps_node.get_tile_in_data(x, y, layer)

func create_object(object, add_to_data):
	return objects_node.create_object(object, add_to_data)

func destroy_object(object, remove_from_data):
	objects_node.destroy_object(object, remove_from_data)

func is_object_at_position(position):
	return objects_node.get_object_at_position(position)

func destroy_object_at_position(position, remove_from_data):
	var object_node = objects_node.get_object_at_position(position)
	if object_node:
		objects_node.destroy_object(object_node, remove_from_data)

func animated_sprite_get_rect(node: AnimatedSprite) -> Rect2:
	# fuck oh god why fuck fuck
	var anim_id : String = node.animation
	var anim_frame : int = node.frame
	
	var texture : Texture = node.frames.get_frame(anim_id, anim_frame)
	var rect := Rect2(0, 0, texture.get_width(), texture.get_height())
	
	if node.centered:
		rect.position -= rect.size / 2
	rect.position += node.offset
	
	return rect

func sprite_is_pixel_opaque_with_margin(sprite: Sprite, point: Vector2, margin: float) -> bool:
	
	if sprite.is_pixel_opaque(point): return true
	if sprite.is_pixel_opaque(point + Vector2(-margin, 0)): return true
	if sprite.is_pixel_opaque(point + Vector2( margin, 0)): return true
	if sprite.is_pixel_opaque(point + Vector2(0, -margin)): return true
	if sprite.is_pixel_opaque(point + Vector2(0,  margin)): return true
	
	return false

# -1 = can't do precise overlap (no sprites)
# 0 = no overlap
# 1 = overlap
func precise_object_overlap(object_node: Node, point: Vector2) -> int:
	var ret_value : int = -1
	
	if object_node is Sprite:
		# Pixel perfect hitbox
		# object_node.is_pixel_opaque(object_node.to_local(point))
		return 1 if sprite_is_pixel_opaque_with_margin(object_node, object_node.to_local(point), 1.0) else 0
	if object_node is AnimatedSprite:
		return 1 if animated_sprite_get_rect(object_node).has_point(object_node.to_local(point)) else 0
	if object_node is NinePatchRect:
		var global_rect = object_node.get_global_rect()
		var grow = 10
		var pos = global_rect.position
		var size = global_rect.size
		var rot = 0
		if "global_rotation" in object_node.get_parent():
			rot = object_node.get_parent().global_rotation + object_node.rect_rotation
		var poly = [
			pos + Vector2(-grow, -grow).rotated(rot),
			pos + (Vector2(grow, -grow) + size * Vector2.RIGHT).rotated(rot),
			pos + (Vector2(grow, grow) + size).rotated(rot),
			pos + (Vector2(-grow, grow) + size * Vector2.DOWN).rotated(rot)]
		return 1 if Geometry.is_point_in_polygon(point, poly) else 0
	
	for child in object_node.get_children():
		ret_value = max(ret_value, precise_object_overlap(child, point))
		if ret_value == 1: break
	
	return ret_value


var __sort_point := Vector2.ZERO
func sort_by_dist_to_point(a: Node2D, b: Node2D) -> bool:
	return a.position.distance_squared_to(__sort_point) < b.position.distance_squared_to(__sort_point)

func get_objects_overlapping_position(point: Vector2):
	
	
	var found_objects = []
	for object_node in objects_node.get_children():
		var editor_hitbox = object_node.get_node_or_null("EditorCircle")
		# for platform wheels
		if is_instance_valid(object_node.get_node_or_null("EditorCircle")):
			if(Vector2().distance_to(object_node.to_local(point)) < editor_hitbox.get_shape().radius):
				found_objects.append(object_node)
		editor_hitbox = object_node.get_node_or_null("EditorHitbox")
		if is_instance_valid(editor_hitbox):
			if editor_hitbox.is_in_point(point):
				found_objects.append(object_node)
		# for resizable platforms
		elif object_node.get_node_or_null("Sprite") is NinePatchRect or object_node.get_node_or_null("Sprite") is ColorRect:
			var rect = object_node.get_node("Sprite").get_rect()
			
			if rect.has_point(object_node.to_local(point)):
				found_objects.append(object_node) 
		
		else:
			var overlap : int = precise_object_overlap(object_node, point)
			
			if overlap == -1:
				overlap = 1 if (object_node.position - point).length() <= 20 else 0
			
			if overlap == 1:
				found_objects.append(object_node)
	
	# Sorting from distance to point hopefully improves selecting overlapping objects
	__sort_point = point
	found_objects.sort_custom(self, "sort_by_dist_to_point")
	
	return found_objects

func destroy_objects_overlapping_position(point: Vector2, remove_from_data):
	var objectsToDelete = get_objects_overlapping_position(point)
	
	for object_node in objectsToDelete:
		if remove_from_data:
			level_area.objects.erase(object_node.level_object)
		object_node.queue_free()

func update_tilemaps():
	tilemaps_node.update_tilemaps()

func toggle_layer_transparency(current_layer, is_transparent):
	var index = 3 # has to be done because for some reason the indices are wrong for the layers
	for tilemap in tilemaps_node.get_children():
		var tilemap_color = Color(1, 1, 1, 1)
		if tilemap.name == "Back" || tilemap.name == "VeryBack":
			tilemap_color = Color(0.54, 0.54, 0.54, 1)
		if index == current_layer:
			tilemap.modulate = tilemap_color
		else:
			if is_transparent:
				tilemap_color.a = 0.25
			tilemap.modulate = tilemap_color
		index = (index + 1) % 4

func move_object_to_back(object):
	objects_node.move_object_to_back(object)

func move_object_to_front(object):
	objects_node.move_object_to_front(object)
