extends GameObject

onready var effects = $ShineEffects
onready var animated_sprite = $AnimatedSprite
onready var ghost = $Ghost
onready var area = $Area2D
onready var sound = $CollectSound
onready var animation_player = $AnimationPlayer
var collected = false
var character

var anim_damp = 160

var title := "Unnamed Shine"
var description := "This is a shine! Collect it to win the level."
var show_in_menu := false
var activated := true
var activate_on := 0

var unpause_timer = 0.0

func _set_properties():
	savable_properties = ["title", "description", "show_in_menu", "activated", "activate_on"]
	editable_properties = ["title", "description", "show_in_menu", "activated", "activate_on"]
	
func _set_property_values():
	set_property("title", title, true)
	set_property("description", description, true)
	set_property("show_in_menu", show_in_menu, true)
	set_property("activated", activated, true)
	set_property("activate_on", activate_on, true)

func collect(body):
	if activated and enabled and !collected and body.name.begins_with("Character") and body.controllable:
		character = body
		character.set_state_by_name("Fall", 0)
		character.velocity = Vector2(0, 0)
		character.get_node("Sprite").rotation_degrees = 0
		character.controllable = false
		#sound.play() -Sound doesn't carry over between scenes, so it cuts off
		collected = true
		visible = false

func _ready():
	if mode != 1:
		if activate_on != 0:
			activated = false
		var _connect = area.connect("body_entered", self, "collect")

func _physics_process(delta):
	if activate_on == 1 and !activated:
		if CurrentLevelData.level_data.vars.red_coins_collected == CurrentLevelData.level_data.vars.max_red_coins:
			activated = true
			animation_player.play("appear")
			var camera = get_tree().get_current_scene().get_node(get_tree().get_current_scene().camera)
			camera.focus_on = self
			pause_mode = PAUSE_MODE_PROCESS
			get_tree().paused = true
			unpause_timer = 3.5
	
	if !animated_sprite.playing:
		animated_sprite.frame = wrapi(OS.get_ticks_msec() / (1000/8), 0, 16)
	if !collected:
		if !activated:
			ghost.visible = true
			animated_sprite.visible = false
			effects.visible = false
		else:
			ghost.visible = false
			animated_sprite.visible = true
			effects.visible = true
	effects.rotation_degrees = (OS.get_ticks_msec()/16) % 360
	effects.position = animated_sprite.offset + Vector2(0, 2)
	if collected:
		var sprite = character.get_node("Sprite")
		sprite.animation = "shineFall"
		if character.is_grounded():
			character.exit()
			
	if unpause_timer > 0:
		unpause_timer -= delta
		if unpause_timer <= 0:
			unpause_timer = 0
			var camera = get_tree().get_current_scene().get_node(get_tree().get_current_scene().camera)
			camera.focus_on = null
			get_tree().paused = false
			pause_mode = PAUSE_MODE_INHERIT
