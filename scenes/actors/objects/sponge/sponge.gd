extends GameObject


onready var sprite = $Sprite
onready var area = $Area2D
onready var area_collision = $Area2D/CollisionShape2D
onready var collision_shape = $StaticBody2D/CollisionShape2D
onready var sponge_range_sprite = $Area2D/ColorRect


var water_drain_speed : float = 15
var water_drain_range : int = 64
var last_range : int

#func _set_properties():
#	savable_properties = ["water_drain_speed", "water_drain_range"]
#	editable_properties = ["water_drain_speed", "water_drain_range"]

func _register_properties():
	register_property(4, "water_drain_speed", water_drain_speed, true)
	register_property(5, "water_drain_range", water_drain_range, true)

func _register_property_info():
	set_property_info("water_drain_speed", PropertyInfo.new("If the player is in range, their F.L.U.D.D. tank will drain at a rate of this%/sec", 1, -INF, INF, ["", ""], ["", ""], false, "Water Drain Speed"))
	set_property_info("water_drain_range", PropertyInfo.new("Effective radius from this.", 1, -INF, INF, ["", ""], ["", ""], false, "Water Drain Range"))
	
func change_size():
	var area_shape = area_collision.get_shape()
	area_shape.extents.x = (16 * sprite.scale.x) + water_drain_range
	area_shape.extents.y = area_shape.extents.x
	sponge_range_sprite.rect_size.x = area_shape.extents.x * 2
	sponge_range_sprite.rect_size.y = sponge_range_sprite.rect_size.x
	sponge_range_sprite.rect_position.x = -area_shape.extents.x
	sponge_range_sprite.rect_position.y = -area_shape.extents.y
	last_range = water_drain_range

func _ready():
	if get_tree().get_current_scene().mode == 0:
		sponge_range_sprite.visible = false
	if !is_enabled_and_on_ground():
		area_collision.disabled = true
		collision_shape.disabled = true
		

func _physics_process(delta):
	if is_enabled_and_on_ground():
		for body in area.get_overlapping_bodies():
			if body is Character:
				body.fuel -= water_drain_speed * delta
			
func _process(_delta):
	if (water_drain_range != last_range):
		change_size()
