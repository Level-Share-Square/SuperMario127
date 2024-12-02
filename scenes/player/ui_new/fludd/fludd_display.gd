extends Control

var display_fuel: float = 100

export var lerp_speed: float = 4
export var editor_offset: float = 78
export var bottom_pos: float = 39

export var character_path: NodePath
onready var character: Character = get_node(character_path)

onready var transition: AnimationPlayer = $Transition
onready var meter: Control = $Meter

onready var counter: Control = $Meter/Counter
onready var tank_left: Polygon2D = $Meter/Tank/Left
onready var tank_right: Polygon2D = $Meter/Tank/Right
onready var tank_top: Polygon2D = $Meter/Tank/Top

onready var paint = $Meter/Paint
onready var icons = $Meter/Icons

var left_default_poly: PoolVector2Array
var right_default_poly: PoolVector2Array


func _ready():
	# waiting for things to ready themselves yada yada
	yield(get_tree(), "physics_frame")
	yield(get_tree(), "physics_frame")
	yield(get_tree(), "physics_frame")
	
	if not is_instance_valid(character):
		queue_free()
		return
	
	if not Singleton.ModeSwitcher.get_node("ModeSwitcherButton").invisible:
		rect_position.x -= editor_offset
	
	character.connect("fludd_activated", self, "fludd_activated")
	character.connect("fludd_deactivated", self, "fludd_deactivated")
	character.connect("nozzle_changed", self, "nozzle_changed")
	if is_instance_valid(character.nozzle):
		nozzle_changed(character.nozzle.name)
	
	left_default_poly = tank_left.polygon
	right_default_poly = tank_right.polygon
	
	display_fuel = character.fuel
	update_visuals(display_fuel)
	
	Singleton.PhotoMode.connect("photo_mode_changed", self, "toggle_photo_mode")
	toggle_photo_mode()


func _physics_process(delta):
	if not is_instance_valid(character): return
		
	if character.fuel != display_fuel:
		display_fuel = lerp(display_fuel, character.fuel, delta * lerp_speed)
		update_visuals(display_fuel)


func update_visuals(new_fuel: float):
	counter.text = str(round(new_fuel)) + "%"
	
	var y_offset: float = bottom_pos * (1 - (new_fuel / 100))
	
	tank_top.position.y = y_offset
	
	var left_poly := left_default_poly
	var right_poly := right_default_poly
	
	left_poly[2].y += y_offset
	left_poly[3].y += y_offset
	
	right_poly[2].y += y_offset
	right_poly[3].y += y_offset
	
	tank_left.polygon = left_poly
	tank_right.polygon = right_poly


var last_nozzle: String = "null"
func nozzle_changed(new_nozzle: String):
	if new_nozzle == last_nozzle: return
	
	if new_nozzle == "null":
		transition.play("transition")
	elif last_nozzle == "null":
		transition.play_backwards("transition")
	
	for child in icons.get_children():
		child.visible = (child.name == new_nozzle)
	last_nozzle = new_nozzle


func fludd_activated():
	paint.is_flashing = true
	icons.do_bounce = true


func fludd_deactivated():
	paint.is_flashing = false
	icons.end_bounce_queued = true
	icons.do_bounce = false


## for the ui hiding stuff
func toggle_photo_mode():
	visible = not Singleton.PhotoMode.enabled
