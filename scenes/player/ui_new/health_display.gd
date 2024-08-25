extends Control

export var character_path: NodePath
onready var character: Character = get_node(character_path)

export (Array, Color) var letter_colors
export (Array, float) var letter_offsets

export var normal_color: Color
export var damaged_color: Color

export var shake_duration: float
export var shake_intensity: float

onready var transition: AnimationPlayer = $Transition

onready var meter: Control = $Meter
onready var animation: AnimationPlayer = $Meter/Actions

onready var segments: Control = $Meter/Segments
onready var letters: HBoxContainer = $Meter/Life

var last_health: int = 8
var last_shards: int = 0
		
func _ready():
	# waiting for things to ready themselves yada yada
	yield(get_tree(), "physics_frame")
	yield(get_tree(), "physics_frame")

	# wait, did the old p2 health ui just stay around even in single player??
	if !is_instance_valid(character):
		queue_free()
		return
	
	$Meter/Idle.play("idle")
	
	character.connect("health_changed", self, "health_changed")
	health_changed(character.health, character.health_shards)
	
	
	Singleton.PhotoMode.connect("photo_mode_changed", self, "toggle_photo_mode")
	toggle_photo_mode()

## shaking animation when damaged
var shake_time: float = -1
func _process(delta):
	if shake_time < 0: return
	
	var shake_amount: float = shake_time * shake_intensity
	meter.rect_position = Vector2(
		rand_range(-1.0, 1.0) * shake_amount,
		rand_range(-1.0, 1.0) * shake_amount
	)
	
	shake_time -= delta
	if shake_time <= 0:
		shake_time = -1
		meter.rect_position = Vector2.ZERO

## most animations called from this function
func health_changed(new_health: int, new_shards: int):
	if new_health != last_health:
		# health animating in and out of the screen
		if new_health == 8:
			transition.play("transition")
		elif last_health == 8:
			transition.play_backwards("transition")
		
		# heal/damage animations
		if new_health > last_health:
			animation.play("heal")
		elif last_health != 8:
			shake_time = shake_duration
		
		# health segments coloring
		update_health_segments(new_health)
		last_health = new_health
	
	# LIFE lettering animations
	if new_shards != last_shards:
		update_shard_segments(new_shards)
		last_shards = new_shards

## update colors of either group of segments
func update_health_segments(new_value: int):
	for segment in segments.get_children():
		segment.color = damaged_color if int(segment.name) > new_value else normal_color

func update_shard_segments(new_value: int):
	var index: int = 0
	for letter in letters.get_children():
		index += 1
		
		if new_value == index or new_value == 0:
			letter.add_color_override("font_color", letter_colors[index])
			animate_letter(letter, letter_offsets[index - 1])
		
		# this isn't an elif cuz i wanted to easily
		# make sure theyre all turned white when u have 0 shards
		if new_value < index:
			letter.add_color_override("font_color", letter_colors[0])

## make those letters do da lil hoppy thing :3
const JUMP_AMOUNT: float = 4.0
const JUMP_SCALE: float = 1.2
const JUMP_DURATION: float = 0.5
func animate_letter(letter: Node, original_y: float):
	var tween: Tween = letter.get_child(0)
	
	tween.stop_all()
	tween.interpolate_property(
		letter, "rect_position:y", original_y - JUMP_AMOUNT, original_y, JUMP_DURATION)
	tween.interpolate_property(
		letter, "rect_scale:y", JUMP_SCALE, 1, JUMP_DURATION)
	tween.start()


## for the ui hiding stuff
func toggle_photo_mode():
	visible = not Singleton.PhotoMode.enabled
