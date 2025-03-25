extends GameObject

enum HideMode {HideAll, Spotlight, Mask}

export var size := Vector2(256, 256)
export(HideMode) var hide_mode: int = 0
export var spotlight_scale: float = 1.0

onready var sprite: Sprite = $Sprite
onready var mask: Light2D = $Mask
onready var area: Area2D = $Area2D
onready var collision_shape: CollisionShape2D = $Area2D/CollisionShape2D
var shared: Node
var tilemaps: Node
var front_tilemap: TileMap

var display: bool = false
var run_process: bool = false


func _set_properties():
	savable_properties = ["size", "hide_mode", "spotlight_scale"]
	editable_properties = ["size", "hide_mode", "spotlight_scale"]


func _set_property_values():
	set_property("size", size, true)
	set_property("hide_mode", hide_mode, true)
	set_property_menu("hide_mode", ["option", 2, 0, ["Hide All", "Spotlight"]])
	
	set_property("spotlight_scale", spotlight_scale, true)


func _ready():
	run_process = true
	
	if is_preview:
		return

	set_property("layer", 3, true)
	set_property_menu("layer", ["option", 1, 3, ["", "", "", "Foreground"]])

	if mode != 1:
		sprite.visible = false
	else:
		var _connect = connect("property_changed", self, "update_property")
		sprite.visible = true

	shared = get_shared()
	tilemaps = shared.get_node("Tilemaps")
	front_tilemap = tilemaps.get_node(tilemaps.front_tilemap)

	update_size()


func _process(delta):
	if is_preview or !get_parent().loaded:
		return
	
	if layer != 3:
		set_property("layer", 3, true)
	
	if mode != 1:
		for body in area.get_overlapping_bodies():
			if body is Character:
				match(hide_mode):
					HideMode.Spotlight:
						body.spotlight.display = true
						body.spotlight.target_scale = spotlight_scale
					HideMode.HideAll:
						front_tilemap.display = true
	else:
		var area_rect = Rect2(-size/2.0, size)

		if area_rect.has_point(get_local_mouse_position()):
			front_tilemap.display = true


func update_property(key, value):
	update_size()


func update_size():
	collision_shape.shape.extents = size/2
	collision_shape.position.y = 0
	
#	mask.scale = hide_size


func _exited(body):
	if body is Character:
		match(hide_mode):
			HideMode.Spotlight:
				body.spotlight.display = false
			
			HideMode.HideAll:
				front_tilemap.display = false
