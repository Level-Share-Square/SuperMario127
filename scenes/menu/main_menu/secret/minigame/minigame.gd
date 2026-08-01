extends Node2D
class_name ConversionMinigame

const FOLDER_SCENE = preload("res://scenes/menu/main_menu/secret/minigame/folder.tscn")
const MAX_FOLDERS: int = 70

onready var timer = $"%Timer"
onready var score_label = $"%ScoreLabel"
onready var folders = $"%Folders"

var score: int = 0

func _ready():
	timer.connect("timeout", self, "add_folder")
	update_score(0)

func update_score(value: int) -> void:
	score += value
	score_label.text = "Score: %d" % score

func update_timer():
	timer.wait_time = clamp(rand_range(0.2, 1.0) - (score/100), 0.2, 1.0)
	
func add_folder():
	update_timer()
	if folders.get_child_count() > MAX_FOLDERS: return
	
	var folder = FOLDER_SCENE.instance()
	folder.position = Vector2(30 + randi() % 200, 0)
	folder.minigame = self
	folders.add_child(folder)
