extends HBoxContainer

const FRAMES_NORMAL = preload("res://scenes/actors/objects/shine/frames_normal.tres")
const FRAMES_RECOLORABLE = preload("res://scenes/actors/objects/shine/frames_recolorable.tres")

onready var title: Label = $Title
onready var time_score_label: Label = $Timescore

# haha get it its the sprite of a shine but theyre also actually called shine sprites and-
onready var shine_sprite: AnimatedSprite = $Sprite/AnimatedSprite
onready var shine_outline_sprite: AnimatedSprite = $Sprite/AnimatedSprite/Outline

var time_score: float = -1
var shine_detail: Dictionary

func _ready():
	var time_score_string : String = "--:--.--"
	if time_score != -1:
		time_score_string = LevelInfo.generate_time_string(time_score)
	
	title.text = shine_detail.title
	time_score_label.text = time_score_string
	
	# Shine color is stored as rgba32 from a json, and json converts stuff to float so it has to be converted twice
	var shine_color: Color = Color(int(shine_detail.color))
	if shine_color != Color.yellow:
		shine_sprite.frames = FRAMES_RECOLORABLE
		shine_sprite.self_modulate = shine_color
	
	shine_sprite.play("default")
	shine_outline_sprite.play("default")
