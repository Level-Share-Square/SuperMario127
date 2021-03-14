#TODO: change this so the top and bottom of the frame can be moved around

extends Screen

onready var tween = $Tween
onready var anim_player = $AnimationPlayer
onready var shine_parent = $ShineParent

onready var level_title = $TextureFrameTop/LevelTitle
onready var level_title_backing = $TextureFrameTop/LevelTitleBacking
onready var shine_title = $TextureFrameTop/ShineTitle
onready var shine_description = $TextureFrameBottom/ShineDescription

onready var button_move_left = $Buttons/ButtonMoveLeft 
onready var button_move_right = $Buttons/ButtonMoveRight 
onready var button_select_shine = $Buttons/ButtonSelectShine 
onready var button_back = $TextureFrameBottom/ButtonBack

onready var background_image = $Background
onready var letsa_go_sfx = $LetsaGo
onready var letsa_go_sfx_2 = $LetsaGo2
onready var mission_select_sfx = $MissionSelect
onready var mission_focus_sfx = $MissionFocus

onready var animation_player = $AnimationPlayer

const PLAYER_SCENE : PackedScene = preload("res://scenes/player/player.tscn")

const SHINE_SPRITE_SCENE = preload("res://scenes/menu/shine_select_screen/shine_sprite.tscn")
const CHANGE_SELECTION_TIME : float = 0.35

# spacing between the shines at different points 
# this should probably be an array now
const SHINE_FIRST_POSITION_OFFSET : float = 125.0
const SHINE_POSITION_INCREMENT : float = 100.0
const SHINE_FIRST_OFFSET_DIFFERENCE = SHINE_FIRST_POSITION_OFFSET - SHINE_POSITION_INCREMENT

# size of the shine at different points
const SHINE_CENTER_SIZE : float = 4.0
const SHINE_BESIDE_CENTER_SIZE : float = 2.0
const SHINE_DEFAULT_SIZE : float = 2.0

# this name is terrible (smh), but basically this variable stores the initial volume of the mission_select_sfx, so it can be muted and then restored to the proper volume
var mission_select_sfx_volume : float = 0

var selected_shine_index : int = 0

# array of all the ShineSprite scene instances used to make the shine select screen work
var shine_sprites : Array = []
# updated with each shine id as it is used, so duplicate shine ids don't happen
var used_shine_ids : Array = []
# contains an array that stores dictionaries containing all the information needed to populate the shine select screen
var shine_details : Array

# An array for the shine indices into the shine_details array, since directly indexing shine_details is unreliable
var shine_details_indices := []

func _ready() -> void:
	# store the initial volume of the mission_select_sfx
	mission_select_sfx_volume = mission_select_sfx.volume_db

	var _connect 
	_connect = button_move_left.connect("pressed", self, "on_button_move_left_pressed")
	_connect = button_move_right.connect("pressed", self, "on_button_move_right_pressed")
	_connect = button_select_shine.connect("pressed", self, "on_button_select_shine_pressed")
	_connect = button_back.connect("pressed", self, "on_button_back_pressed")

	# also connect to the signal for animations being finished, this will be used to restart the main menu music at the right part of the transition
	_connect = anim_player.connect("animation_finished", self, "on_animation_finished")

func _open_screen() -> void:
	mission_select_sfx.volume_db = -80.0 if Singleton.Music.muted else mission_select_sfx_volume
	mission_select_sfx.play();

	var selected_level = Singleton.SavedLevels.selected_level
	shine_details = Singleton.SavedLevels.get_current_levels()[selected_level].shine_details
	background_image.texture = Singleton.SavedLevels.get_current_levels()[selected_level].get_level_background_texture()

	used_shine_ids = []
	
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
			
		# place all the shines the correct distance away from the center shine
		if i > 1:
			shine_sprite.position.x = SHINE_FIRST_POSITION_OFFSET + (SHINE_POSITION_INCREMENT * i)
		elif i == 1:
			shine_sprite.position.x = SHINE_FIRST_POSITION_OFFSET 
		
		# has to be called deferred as we only *just* instanced these scenes, the method doesn't exist yet to be called
		shine_sprite.call_deferred("start_animation")
		
		# if the shine isn't collected, make it blue on the shine select scree
		# if it is collected, show the correct colour of the shine
		var collected_shines = Singleton.SavedLevels.get_current_levels()[selected_level].collected_shines
		var is_collected = collected_shines[str(shine_details[i]["id"])]
		if !is_collected: 
			shine_sprite.make_blue()
		else:
			# Shine color is stored as rgba32 from a json, and json converts stuff to float so it has to be converted twice
			shine_sprite.set_color(Color(int(shine_details[i]["color"])))
		
		shine_sprite.add_to_group("shine_sprites")
		shine_parent.add_child(shine_sprite)
	
	selected_shine_index = 0
	move_shine_sprites() # make sure everything is in the right spot and size and such
	update_labels()

func _close_screen():
	# get rid of these when closing so if you go back then select another level it generates properly
	for shine_sprite in shine_sprites:
		shine_sprite.queue_free()
	shine_sprites = []

func _input(_event: InputEvent) -> void:
	if !can_interact:
		return

	if Input.is_action_just_pressed("ui_right"):
		attempt_increment_selected_shine_index(1)
	elif Input.is_action_just_pressed("ui_left"):
		attempt_increment_selected_shine_index(-1)
	elif Input.is_action_just_pressed("ui_accept"):
		start_level()
	elif Input.is_action_just_pressed("ui_cancel"):
		emit_signal("screen_change", "shine_select_screen", "levels_screen")

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
	level_title.text = Singleton.SavedLevels.get_current_levels()[Singleton.SavedLevels.selected_level].level_name
	level_title_backing.text = level_title.text
	shine_title.text = shine_details[shine_details_indices[selected_shine_index]]["title"]
	shine_description.text = shine_details[shine_details_indices[selected_shine_index]]["description"]

func start_level() -> void:
	letsa_go_sfx.play()
	if Singleton.PlayerSettings.number_of_players > 1:
		# quick wait before playing P2's voice clip, to make it sound more natural
		yield(get_tree().create_timer(0.035), "timeout")
		
		# we set the array index so the same voice is played for both, and it syncs
		letsa_go_sfx_2.array_index = letsa_go_sfx.array_index
		letsa_go_sfx_2.play()

	can_interact = false
	
	get_tree().call_group("shine_sprites", "start_pressed_animation")

	Singleton.SavedLevels.get_current_levels()[Singleton.SavedLevels.selected_level].selected_shine = shine_details_indices[selected_shine_index]
	
	# levels screen is supposed to set the CurrentLevelData before changing to the shine select screen
	# so we'll assume it's safe to just go straight to the player scene 
	animation_player.play("select_shine")
	animation_player.connect("animation_finished", self, "change_to_player_scene", [], CONNECT_ONESHOT)

# signal responses start here 

func on_button_move_left_pressed() -> void:
	attempt_increment_selected_shine_index(-1)

func on_button_move_right_pressed() -> void:
	attempt_increment_selected_shine_index(1)

func on_button_select_shine_pressed() -> void:
	start_level()

func on_button_back_pressed() -> void:
	emit_signal("screen_change", "shine_select_screen", "levels_screen")

func on_animation_finished(anim_name : String) -> void:
	# this string could be made into a constant, but it's only gonna be used once and it's so specific it'd only hurt readability
	if anim_name == "trans_out_ShineSelectScreen_LevelsScreen":
		# change music back
		Singleton.Music.change_song(0, Singleton.Music.last_song)
		mission_select_sfx.stop();

# unlike the rest of the signals, this is connected in the start_level function
func change_to_player_scene(_animation : String) -> void:
	# Start fading out now; the transition has finished
	Singleton.SceneTransitions.do_transition_fade(Singleton.SceneTransitions.DEFAULT_TRANSITION_TIME,\
	Color(1, 1, 1, 1), Color(1, 1, 1, 0), false)

	var _change_scene = get_tree().change_scene_to(PLAYER_SCENE)

