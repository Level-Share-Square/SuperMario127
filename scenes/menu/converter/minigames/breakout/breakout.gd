extends Node2D

const BOX_SCENE: PackedScene = preload("res://scenes/menu/converter/minigames/breakout/box.tscn")

onready var playable_rect = $PlayableRect
onready var paddle = $"%Paddle"
onready var pause_container = $"%PauseContainer"
onready var boxes = $Boxes
onready var tween = $Tween
onready var score_anim_player = $"%ScoreAnimPlayer"
onready var score_counter = $"%ScoreCounter"
onready var high_score_anim_player = $"%HighScoreAnimPlayer"
onready var high_score_counter = $"%HighScoreCounter"
onready var fireball = $"%Fireball"
onready var level_anim_player = $"%LevelAnimPlayer"
onready var level_label = $"%LevelLabel"
onready var lives_container = $"%LivesContainer"
onready var character = $"%Character"
onready var all_hit = $AllHit

var paused: bool
var score: int
var level: int
var lives: int = 3


func update_branch_paused() -> void:
	fireball.set_physics_process(not paused)
	fireball.set_process(not paused)
	
	tween.stop_all()
	tween.interpolate_property(
		paddle,
		"modulate:a",
		paddle.modulate.a,
		1.0 if not paused else 0.0,
		0.5,
		Tween.TRANS_CIRC,
		Tween.EASE_OUT
	)
	tween.interpolate_property(
		pause_container,
		"modulate:a",
		pause_container.modulate.a,
		1.0 if paused else 0.0,
		0.5,
		Tween.TRANS_CIRC,
		Tween.EASE_OUT
	)
	tween.start()


func populate_boxes() -> void:
	for box in boxes.get_children():
		box.queue_free()
	
	var play_width: float = playable_rect.get_node("CollisionShape2D").shape.extents.x * 2
	var box_size := Vector2(48, 24)
	for x in range(floor(play_width / box_size.x)):
		for y in range(6):
			var box: StaticBody2D = BOX_SCENE.instance()
			box.position = Vector2(x, y) * box_size
			box.get_node("Sprite").region_rect.position.y = box.position.y
			box.connect("award_points", self, "award_points")
			box.connect("box_broken", self, "check_level_completed")
			boxes.add_child(box)


func _ready():
	fireball.connect("life_lost", self, "lose_life")
	update_high_score(false)
	populate_boxes()


func _physics_process(_delta):
	var rect_empty: bool = true
	for overlapping_area in playable_rect.get_overlapping_areas():
		if overlapping_area.name == "PlayerCollision":
			rect_empty = false
	
	if rect_empty and not paused:
		paused = true
		update_branch_paused()
	elif not rect_empty and paused:
		paused = false
		update_branch_paused()


func award_points(amount: int, color: Color = Color.white) -> void:
	set_score(score + amount, color)


func set_score(new_score: int, color: Color = Color.white) -> void:
	score = new_score
	score_anim_player.play("collect")
	score_counter.text = str(round(score)).pad_zeros(6)
	score_counter["custom_colors/font_color"] = color
	var tween: SceneTreeTween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(score_counter, "custom_colors/font_color", Color.white, 0.3)


func check_level_completed() -> void:
	if boxes.get_child_count() <= 1:
		set_level()
		award_points(5000, Color(1, 1, 0.5))
		all_hit.play()


func set_level(new_level: int = level + 1) -> void:
	level = new_level
	level_anim_player.play("collect")
	level_label.text = str(level + 1)
	populate_boxes()
	fireball.to_spawn()


func lose_life() -> void:
	if lives > 0:
		lives_container.get_node("Life%s/AnimationPlayer" % str(lives)).play("hide")
		lives -= 1
	else:
		game_over()


func game_over() -> void:
	for life in lives_container.get_children():
		life.get_node("AnimationPlayer").play_backwards("hide")
	lives = 3
	update_high_score(true)
	set_score(0)
	set_level(0)
	character.sound_player.play_death_sound()


## im being a bit coy cos i dont want people to set it in cfg and show it off as if they did it
func update_high_score(upload_score: bool = true) -> void:
	var high_score: int = LevelCodeDeserializer.base64_decode_int(LocalSettings.load_setting("Misc", "brk_hs", "A"))
	if score > high_score:
		if upload_score:
			high_score = score
			LocalSettings.change_setting("Misc", "brk_hs", LevelCodeSerializer.base64_encode_int(high_score))
		high_score_anim_player.play("collect")
	high_score_counter.text = str(round(high_score)).pad_zeros(6)
