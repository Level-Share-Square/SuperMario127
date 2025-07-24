extends Node2D

## level data
onready var level_info: LevelInfo = Singleton.CurrentLevelData.level_info

## nodes
onready var tween: Tween = $"%Tween"
onready var shine_title: Label = $"%ShineTitle"
onready var shine_description: RichTextLabel = $"%ShineDescription"

onready var mission_focus_sfx: AudioStreamPlayer = $"%MissionFocus"

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

var scrollable_shines: Array = [0]

var selected_shine_index: int = -1

func _ready():
	shine_details = level_info.shine_details
	
	var shine_index: int = 0
	var final_select_shine: bool = false
	for i in range(shine_details.size()):
		var end: bool = false
		
		var collected_shines = level_info.collected_shines
		var is_collected = collected_shines[str(shine_details[i]["id"])]
		if used_shine_ids.has(shine_details[i]["id"]):
			continue
		if !shine_details[i]["show_in_menu"]:
			continue
		if Singleton.CurrentLevelData.shine_progression:
			if is_collected:
				scrollable_shines.append(i)
			if !is_collected && final_select_shine == false:
				scrollable_shines.append(i if i != 0 else 1)
				final_select_shine = true
			if (i == find_last_collected_shine()) || find_last_collected_shine() == -1:
				end = true

		used_shine_ids.append(shine_details[i]["id"])

		var shine_sprite = SHINE_SPRITE_SCENE.instance()
		shine_sprites.append(shine_sprite)
		shine_details_indices.append(i)
		
		# make non-kickout shines turn the other way
		if "do_kick_out" in shine_details[i]:
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
		if !is_collected:
			# automatically select first empty shine
			if selected_shine_index == -1:
				selected_shine_index = shine_index
			shine_sprite.make_blue()
		else:
			# Shine color is stored as rgba32 from a json, and json converts stuff to float so it has to be converted twice
			shine_sprite.set_color(Color(int(shine_details[i]["color"])))
		
		shine_index += 1
		shine_sprite.add_to_group("shine_sprites")
		add_child(shine_sprite)
		
		if final_select_shine:
			if (i == 1 && i - 1 == find_last_collected_shine()):
				break
		if end:
			if i == 0 && find_last_collected_shine() != -1:
				end = false
			else:
				break
	
	selected_shine_index = max(0, selected_shine_index)
	get_child(selected_shine_index).selected = true
	
	move_shine_sprites(true) # make sure everything is in the right spot and size and such
	update_labels()
	print(scrollable_shines)

func _input(event):
	if Input.is_action_just_pressed("ui_right"):
		if Singleton.CurrentLevelData.shine_progression:
			if scrollable_shines.size() > 1:
				var scrollable_index: int = scrollable_shines.find(selected_shine_index)
				var scroll_amount = scrollable_shines[scrollable_index + 1] - scrollable_shines[scrollable_index] if scrollable_index + 1 < scrollable_shines.size() else 1
				attempt_increment_selected_shine_index(scroll_amount if scroll_amount != 0 else 1)
			return
		attempt_increment_selected_shine_index(1)
	elif Input.is_action_just_pressed("ui_left"):
		if Singleton.CurrentLevelData.shine_progression:
			if scrollable_shines.size() > 1:
				var scrollable_index: int = scrollable_shines.find(selected_shine_index)
				var scroll_amount = scrollable_shines[scrollable_index - 1] - scrollable_shines[scrollable_index]
				attempt_increment_selected_shine_index(scroll_amount if selected_shine_index != 0 else 0)
			return
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
	selected_shine_index = clamp(selected_shine_index + increment, 0, shine_sprites.size() - 1 if !Singleton.CurrentLevelData.shine_progression else scrollable_shines.back())
	# no point in doing anything if the value didn't actually change
	if selected_shine_index == previous_selected_shine_index:
		return

	shine_sprites[previous_selected_shine_index].selected = false
	shine_sprites[selected_shine_index].selected = true

	mission_focus_sfx.play()
	move_shine_sprites()
	update_labels()
	
func move_shine_sprites(instant: bool = false) -> void:
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
		
		var tween_time = CHANGE_SELECTION_TIME if not instant else 0.0001
		# smoothly interplate to the new scale, position, and alpha value
		tween.interpolate_property(shine_sprites[i], "scale", null, Vector2(shine_size, shine_size), \
				tween_time, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		tween.interpolate_property(shine_sprites[i], "position:x", null, target_position_x, \
				tween_time, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		tween.interpolate_property(shine_sprites[i], "modulate:a", null, shine_transparency, \
				tween_time, Tween.TRANS_CUBIC, Tween.EASE_OUT)

	tween.start()

func update_labels() -> void:
	# this will assume the selected shine and the selected level are valid
	shine_title.text = shine_details[shine_details_indices[selected_shine_index]]["title"]
	shine_description.bbcode_text = (
		"[center]" +
		shine_details[shine_details_indices[selected_shine_index]]["description"] +
		"[/center]"
	)

func find_last_collected_shine() -> int:
	var collected_shines = level_info.collected_shines
	var shine_index = -1
	for shine in collected_shines:
		if collected_shines[shine]:
			shine_index = shine
	return int(shine_index)
