extends Control

var move_speed := 216.0
onready var area = $Area2D
onready var block_area = $BlockArea
onready var animation_player = $AnimationPlayer

var blocks_hit = 0

func _ready():
#	move_speed = 0
#	yield(get_tree().create_timer(5), "timeout")
#	move_speed = 216.0
	OS.set_window_title("Super Mario 127 (Loading...)")
	var _connect = area.connect("area_entered", self, "collect_coin")
	_connect = block_area.connect("area_entered", self, "hit_block")

func hit_block(detected_area):
	if get_tree().get_current_scene().coins_spawned < detected_area.get_parent().coin_requirement: return
	if blocks_hit < detected_area.get_parent().block_index: return
	
	if detected_area.get_parent().is_last:
		move_speed = 0
		get_tree().get_current_scene().get_node("AnimationPlayer").play("FadeOut")
		animation_player.play("JumpLast")
		detected_area.get_parent().get_node("AnimationPlayer").play("Hit")
	else:
		animation_player.play("Jump")
		detected_area.get_parent().get_node("AnimationPlayer").play("Hit")
	
	blocks_hit += 1

func collect_coin(area):
	var coin = area.get_parent()
	coin.collect()

func _physics_process(delta):
	rect_position.x += move_speed * delta * 0.75
	
	if rect_position.x > 768:
		rect_position.x = -48
