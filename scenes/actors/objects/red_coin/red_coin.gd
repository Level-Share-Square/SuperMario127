extends GameObject

onready var animated_sprite = $AnimatedSprite
onready var sound = $AudioStreamPlayer
onready var last_sound = $LastCollect
onready var area = $Area2D
onready var visibility_enabler = $VisibilityEnabler2D
onready var label = $Label
onready var sparkles = $Sparkles

var collected = false
var physics = false
var gravity : float
var velocity : Vector2

var id : int

export var anim_damp = 80

func collect(body):
	if enabled and !collected and body.name.begins_with("Character") and !body.dead:
		Singleton.CurrentLevelData.level_data.vars.collect_coin(2)
		Singleton.CurrentLevelData.level_data.vars.collect_red_coin(id)
		body.heal(5)
		var player_id = 1
		if body.name == "Character":
			player_id = 0
		if Singleton.PlayerSettings.other_player_id == -1 or Singleton.PlayerSettings.my_player_index == player_id:
			if Singleton.CurrentLevelData.level_data.vars.red_coins_collected[0] != Singleton.CurrentLevelData.level_data.vars.max_red_coins:
				sound.play()
			else:
				last_sound.play()
		collected = true
		label.text = str(Singleton.CurrentLevelData.level_data.vars.red_coins_collected[0])
		label.visible = true
		animated_sprite.animation = "collect"
		animated_sprite.frame = 0
		sparkles.emitting = false
		yield(get_tree().create_timer(2.0), "timeout")
		queue_free() # die
		
func _ready():
	if mode == 1: return
	if enabled:
		id = Singleton.CurrentLevelData.level_data.vars.last_red_coin_id + Singleton.CurrentLevelData.get_red_coins_before_area(Singleton.CurrentLevelData.area)
		Singleton.CurrentLevelData.level_data.vars.last_red_coin_id += 1
	
	if id in Singleton.CurrentLevelData.level_data.vars.red_coins_collected[1]:
		queue_free()
	
	var _connect = area.connect("body_entered", self, "collect")

func _process(delta):
	if !collected:
		animated_sprite.frame = (OS.get_ticks_msec() / anim_damp) % 4
	else:
		var label_color = label.modulate
		label_color.a -= 0.035
		label.modulate = label_color
		label.rect_position.y -= 0.75
