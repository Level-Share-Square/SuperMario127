extends Node2D

## level data
onready var level_info: LevelInfo = Singleton.CurrentLevelData.level_info

## nodes
onready var tween: Tween = get_node("%Tween")
onready var shine_title: Label = get_node("%ShineTitle")
onready var shine_description: RichTextLabel = get_node("%ShineDescription")

onready var mission_focus_sfx: AudioStreamPlayer = get_node("%MissionFocus")

## visual stuff
const SHINE_SPRITE_SCENE: PackedScene = preload("res://scenes/menu/shine_select/shine_sprite.tscn")
const CHANGE_SELECTION_TIME: float = 0.35

# spacing between the shines at different points 
# this should probably be an array now
const SHINE_FIRST_POSITION_OFFSET: float = 125.0
const SHINE_POSITION_INCREMENT: float = 100.0
const SHINE_FIRST_OFFSET_DIFFERENCE: float = SHINE_FIRST_POSITION_OFFSET - SHINE_POSITION_INCREMENT

# size of the shine at different points
const SHINE_CENTER_SIZE: float = 4.0
const SHINE_BESIDE_CENTER_SIZE: float = 2.0
const SHINE_DEFAULT_SIZE: float = 2.0

## vars
var can_interact: bool = true
# array of all the ShineSprite scene instances used to make the shine select screen work
var shine_sprites: Array = []
# updated with each shine id as it is used, so duplicate shine ids don't happen
var used_shine_ids: Array = []
# An array for the shine indices into the shine_details array, since directly indexing shine_details is unreliable
var shine_details_indices: Array = []
# contains an array that stores dictionaries containing all the information needed to populate the shine select screen
var shine_details: Array = []

var selected_shine_index: int = 0

func _ready():
	shine_details = level_info.shine_details
	for i in range(shine_details.size()):
		if used_shine_ids.has(shine_details[i]["id"]):
			continue
		if !shine_details[i]["show_in_menu"]:
			continue

		used_shine_ids.append(shine_details[i]["id"])

		var shine_sprite = SHINE_SPRITE_SCENE.instance()
		shine_sprites.append(shine_sprite)
		shine_details_indices.append(i)
		
		# mark the selected shine and only that shine as selected
		shine_sprite.selected = i == 0
		
		# make non-kickout shines turn the other way
		shine_sprite.is_flipped = !shine_details[i]["do_kick_out"]
		
		# place all the shines the correct distance away from the center shine
		if i > 1:
			shine_sprite.position.x = SHINE_FIRST_POSITION_OFFSET + (SHINE_POSITION_INCREMENT * i)
		elif i == 1:
			shine_sprite.position.x = SHINE_FIRST_POSITION_OFFSET 
		
		# has to be called deferred as we only *just* instanced these scenes, the method doesn't exist yet to be called
		shine_sprite.call_deferred("start_animation")
		
		# if the shine isn't collected, make it blue on the shine select scree
		# if it is collected, show the correct colour of the shine
		var collected_shines = level_info.collected_shines
		var is_collected = collected_shines[str(shine_details[i]["id"])]
		if !is_collected: 
			shine_sprite.make_blue()
		else:
			# Shine color is stored as rgba32 from a json, and json converts stuff to float so it has to be converted twice
			shine_sprite.set_color(Color(int(shine_details[i]["color"])))
		
		shine_sprite.add_to_group("shine_sprites")
		add_child(shine_sprite)
	
	move_shine_sprites() # make sure everything is in the right spot and size and such
	update_labels()

func _input(event):
	if Input.is_action_just_pressed("ui_right"):
		attempt_increment_selected_shine_index(1)
	elif Input.is_action_just_pressed("ui_left"):
		attempt_increment_selected_shine_index(-1)
	elif Input.is_action_just_pressed("ui_accept"):
		get_parent().start_level()
	elif Input.is_action_just_pressed("ui_cancel"):
		get_parent().back()


# this will try to change the selected shine, but won't if you're already at the first or last shine
func attempt_increment_selected_shine_index(increment : int) -> void:
	if !can_interact:
		return

	var previous_selected_shine_index = selected_shine_index
	# warning-ignore:narrowing_conversion
	selected_shine_index = clamp(selected_shine_index + increment, 0, shine_sprites.size() - 1)

	# no point in doing anything if the value didn't actually change
	if selected_shine_index == previous_selected_shine_index:
		return

	shine_sprites[previous_selected_shine_index].selected = false
	shine_sprites[selected_shine_index].selected = true

	mission_focus_sfx.play()
	move_shine_sprites()
	update_labels()
	
func move_shine_sprites() -> void:
	for i in range(shine_sprites.size()):
		var shine_size = SHINE_DEFAULT_SIZE
		var target_position_x : float

		# middle shine is opaque, next is 0.75 alpha, after that is 0.5, etc
		var shine_transparency = max(0, 1 - abs(0.25 * (selected_shine_index - i)))

		# based on the position of the shine relative to the center, set the scale and position
		if i == selected_shine_index:
			shine_size = SHINE_CENTER_SIZE
			target_position_x = 0 
		elif abs(i - selected_shine_index) == 1:
			target_position_x = SHINE_FIRST_POSITION_OFFSET * sign(i - selected_shine_index)
		elif abs(i - selected_shine_index) > 1:
			# this comment won't make sense if the values change, current values are first offset 125 then increment 100
			# shine 2 on the right would be at 225, shine 3 at 325, shine 2 on the left at 225, etc
			target_position_x = (SHINE_FIRST_OFFSET_DIFFERENCE + (abs(i - selected_shine_index) * \
					SHINE_POSITION_INCREMENT)) * sign(i - selected_shine_index)
			
		# smoothly interplate to the new scale, position, and alpha value
		tween.interpolate_property(shine_sprites[i], "scale", null, Vector2(shine_size, shine_size), \
				CHANGE_SELECTION_TIME, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		tween.interpolate_property(shine_sprites[i], "position:x", null, target_position_x, \
				CHANGE_SELECTION_TIME, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		tween.interpolate_property(shine_sprites[i], "modulate:a", null, shine_transparency, \
				CHANGE_SELECTION_TIME, Tween.TRANS_CUBIC, Tween.EASE_OUT)

	tween.start()

func update_labels() -> void:
	# this will assume the selected shine and the selected level are valid
	shine_title.text = shine_details[shine_details_indices[selected_shine_index]]["title"]
	shine_description.bbcode_text = (
		"[center]" +
		shine_details[shine_details_indices[selected_shine_index]]["description"] +
		"[/center]"
	)
