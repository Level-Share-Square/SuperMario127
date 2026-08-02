extends GameObject

onready var animated_sprite = $AnimatedSprite
onready var sound = $AudioStreamPlayer
onready var last_sound = $LastCollect
onready var area = $Area2D
onready var visibility_enabler = $VisibilityEnabler2D
onready var label = $Label
onready var sparkles = $Sparkles
onready var animation_player = $AnimationPlayer

var collected = false
var physics = false
var velocity : Vector2

var id : Array

export var anim_damp = 80

func collect(body):
	if is_enabled_and_on_ground() and !collected and body.name.begins_with("Character") and !body.dead:
		CurrentLevelData.vars.collect_coin(2)
		CurrentLevelData.vars.collect_red_coin(id)
		body.heal(5)
		var player_id = 1
		if body.name == "Character":
			player_id = 0
		if Singleton.PlayerSettings.other_player_id == -1 or Singleton.PlayerSettings.my_player_index == player_id:
			if CurrentLevelData.vars.red_coins_collected[0] != CurrentLevelData.level_metadata.collectible_data.red_coin_count:
				sound.play()
			else:
				last_sound.play()
		collected = true
		label.text = str(CurrentLevelData.vars.red_coins_collected[0])
		animation_player.play("collect")
		
func _ready():
	animation_player.play("RESET")
	if mode == 1: return
	if is_enabled_and_on_ground():
		id = [position, CurrentLevelData.area_id]
		if id in CurrentLevelData.vars.red_coins_collected[1]:
			queue_free()
	
	var _connect = area.connect("body_entered", self, "collect")

func _process(delta):
	if !collected:
		animated_sprite.frame = (OS.get_ticks_msec() / anim_damp) % 4
