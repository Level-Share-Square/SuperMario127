extends GameObject

onready var animated_sprite = $AnimatedSprite
onready var sound = $AudioStreamPlayer
onready var area = $Area2D
onready var visibility_enabler = $VisibilityEnabler2D

var collected = false
var physics = false
var destroy_timer = 0.0
var despawn_timer = 0.0
var gravity : float
var velocity : Vector2

var id : int
var timer

export var anim_damp = 80

func collect(body):
	if enabled and !collected and body.name.begins_with("Character") and !body.dead:
		Singleton.CurrentLevelData.level_data.vars.collect_purple_starbit(id)
		var player_id = 1
		if body.name == "Character":
			player_id = 0
		if Singleton.PlayerSettings.other_player_id == -1 or Singleton.PlayerSettings.my_player_index == player_id:
			sound.play()
		collected = true
		animated_sprite.animation = "collect"
		animated_sprite.frame = 0
		destroy_timer = 2
		
func _ready():
	if mode == 1: return
	if enabled:
		id = Singleton.CurrentLevelData.level_data.vars.max_purple_starbits
		Singleton.CurrentLevelData.level_data.vars.max_purple_starbits += 1
	
	if id in Singleton.CurrentLevelData.level_data.vars.purple_starbits_collected[Singleton.CurrentLevelData.area][1]:
		queue_free()
	
	var _connect = area.connect("body_entered", self, "collect")

func _process(delta):
	if destroy_timer > 0:
		destroy_timer -= delta
		if destroy_timer <= 0:
			destroy_timer = 0
			queue_free()
	if despawn_timer > 0:
		despawn_timer -= delta
		if despawn_timer <= 1:
			visible = !visible
		if despawn_timer <= 0:
			if !sound.playing:
				despawn_timer = 0
				queue_free()
			else:
				despawn_timer = 0.3
	if !collected:
		animated_sprite.frame = wrapi(OS.get_ticks_msec() / (1000/8), 0, 16)
