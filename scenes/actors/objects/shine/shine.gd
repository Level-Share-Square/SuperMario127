# TODO: 
# Shine Dance frames for fludd 
# Update ambient sound volume to consider both players (check cannon audio source script)
extends GameObject

onready var animated_sprite = $AnimatedSprite
onready var ghost = $Ghost
onready var area = $Area2D
onready var collect_sound = $CollectSound
onready var ambient_sound = $AmbientSound
onready var animation_player = $AnimationPlayer
onready var transitions = get_node("/root/scene_transitions")

onready var course_clear_music = preload("res://assets/music/course_clear.ogg")

onready var current_scene = get_tree().current_scene
var collected = false
var character

var anim_damp = 160

var title := "Unnamed Shine"
var description := "This is a shine! Collect it to win the level."
var show_in_menu := false
var activated := true
var red_coins_activate := false
var shine_shards_activate := false

var unpause_timer = 0.0

func _set_properties():
	savable_properties = ["title", "description", "show_in_menu", "activated", "red_coins_activate", "shine_shards_activate"]
	editable_properties = ["title", "description", "show_in_menu", "activated", "red_coins_activate", "shine_shards_activate"]
	
func _set_property_values():
	set_property("title", title, true)
	set_property("description", description, true)
	set_property("show_in_menu", show_in_menu, true)
	set_property("activated", activated, true)
	set_property("red_coins_activate", red_coins_activate, true)
	set_property("shine_shards_activate", shine_shards_activate, true)

func collect(body):
	if activated and enabled and !collected and body.name.begins_with("Character") and body.controllable:
		character = body
		character.set_state_by_name("Fall", 0)
		character.velocity.x = 0
		character.sprite.rotation_degrees = 0
		character.controllable = false
		collect_sound.play() 
		collected = true
		visible = false

func _ready():
	if mode != 1:
		if red_coins_activate or shine_shards_activate:
			activated = false
		var _connect = area.connect("body_entered", self, "collect")

func _physics_process(delta):
	if !animated_sprite.playing:
		#warning-ignore:integer_division
		animated_sprite.frame = wrapi(OS.get_ticks_msec() / (1000/8), 0, 16)
	if mode != 1:
		var camera = current_scene.get_node(current_scene.camera)
		if red_coins_activate and !activated:
			if CurrentLevelData.level_data.vars.red_coins_collected == CurrentLevelData.level_data.vars.max_red_coins:
				activate_shine()
		if shine_shards_activate and !activated:
			if CurrentLevelData.level_data.vars.shine_shards_collected == CurrentLevelData.level_data.vars.max_shine_shards:
				activate_shine()
		if !collected:
			if !activated:
				ambient_sound.playing = false
				ghost.visible = true
				animated_sprite.visible = false
			else:
				if !ambient_sound.playing:
					ambient_sound.playing = true
				ghost.visible = false
				animated_sprite.visible = true
		ambient_sound.volume_db = -16 + -abs(camera.global_position.distance_to(global_position)/25)
	if collected:
		var sprite = character.get_node("Sprite")
		sprite.animation = "shineFall"
		character.sprite.rotation_degrees = 0
		
		ambient_sound.playing = false 
		music.playing = false
		
		if character.is_grounded():
			character.set_state_by_name("NoActionState", delta)

			character.collected_shine.modulate = animated_sprite.modulate
			character.sprite.animation = "shineDance"
			character.anim_player.play("shine_dance")
			
			music.stream = course_clear_music
			music.orig_volume = -7.5
			music.play()
			
			character.anim_player.connect("animation_finished", self, "character_shine_dance_finished")
			
			set_physics_process(false)
			
	if unpause_timer > 0:
		unpause_timer -= delta
		if unpause_timer <= 0:
			unpause_timer = 0
			var camera = current_scene.get_node(current_scene.camera)
			camera.focus_on = null
			get_tree().paused = false
			pause_mode = PAUSE_MODE_INHERIT

func activate_shine():
	activated = true
	animation_player.play("appear")
	var camera = current_scene.get_node(current_scene.camera)
	camera.focus_on = self
	pause_mode = PAUSE_MODE_PROCESS
	get_tree().paused = true
	unpause_timer = 3.35

func character_shine_dance_finished(_animation):
	yield(get_tree().create_timer(1.25), "timeout")
	
	if mode_switcher.get_node("ModeSwitcherButton").invisible: #if not running through the editor, play the fancy transition
		transitions.reload_scene(character.cutout_shine, character.cutout_circle, transitions.DEFAULT_TRANSITION_TIME, 0, true)
	else:
		mode_switcher.get_node("ModeSwitcherButton")._pressed()
