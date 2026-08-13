extends Node2D

const BOX_SCENE: PackedScene = preload("res://scenes/menu/converter/minigames/breakout/box.tscn")

onready var playable_rect = $PlayableRect
onready var paddle = $"%Paddle"
onready var pause_container = $"%PauseContainer"
onready var boxes = $Boxes
onready var tween = $Tween
onready var score_anim_player = $"%ScoreAnimPlayer"
onready var score_counter = $"%ScoreCounter"

var paused: bool
var score: int


func update_branch_paused(parent: Node = self) -> void:
	for child in parent.get_children():
		if not child is Area2D:
			child.set_physics_process(not paused)
			update_branch_paused(child)
	
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
			boxes.add_child(box)


func _ready():
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
	score += amount
	score_anim_player.play("collect")
	score_counter.text = str(round(score)).pad_zeros(6)
	score_counter["custom_colors/font_color"] = color
	var tween: SceneTreeTween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(score_counter, "custom_colors/font_color", Color.white, 0.3)
