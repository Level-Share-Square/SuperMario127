extends VBoxContainer

const HIDDEN_TITLE: String = "???"

const SHINE_SCENE: PackedScene = preload("res://scenes/menu/pause/shine_map/shine.tscn")
const FRAMES_COLLECTED: SpriteFrames = preload("res://scenes/actors/objects/shine/frames_collected.tres")
const FRAMES_RECOLORABLE: SpriteFrames = preload("res://scenes/actors/objects/shine/frames_recolorable.tres")

const STAR_COIN_SCENE: PackedScene = preload("res://scenes/menu/pause/shine_map/star_coin.tscn")
const COIN_FRAMES_COLLECTED: SpriteFrames = preload("res://scenes/actors/objects/star_coin/collected_frames.tres")

onready var title = $"%Title"
onready var shines = $"%Shines"
onready var star_coins = $"%StarCoins"
var level_dict: Dictionary


func _ready():
	populate(level_dict)

func populate(level_dict: Dictionary) -> void:
	var is_hidden: bool = false
	var collected_shines: Array = level_dict.get("collected_shines", [])
	var collected_star_coins: Array = level_dict.get("collected_star_coins", [])
	
	if collected_shines.count(true) <= 0 and collected_star_coins.count(true) <= 0:
		is_hidden = true
	title.text = HIDDEN_TITLE if is_hidden else level_dict.get("name", "Unknown Level")
	
	var shine_details: Array = level_dict.get("shine_details", [])
	var shine_times: Array = level_dict.get("shine_times", [])
	
	if shine_details == []:
		shine_details.resize(collected_shines.size())
		shine_details.fill({})
	if shine_times == []:
		shine_times.resize(collected_shines.size())
		shine_times.fill(-1)
	
	for shine_id in range(collected_shines.size()):
		add_shine(collected_shines[shine_id], shine_details[shine_id], shine_times[shine_id], is_hidden)
	
	for is_collected in collected_star_coins:
		add_star_coin(is_collected)


func add_shine(is_collected: bool, shine_dictionary: Dictionary, time_score: int, is_hidden: bool):
	var shine: Control = SHINE_SCENE.instance()
	var sprite: AnimatedSprite = shine.get_node("AnimatedSprite")
	var outline: AnimatedSprite = shine.get_node("AnimatedSprite/Outline")
	
	if is_collected:
		# Shine color is stored as rgba32 from a json, and json converts stuff to float so it has to be converted twice
		var shine_color: Color = Color(int(shine_dictionary.get("color", Color.yellow.to_rgba32())))
		if shine_color != Color.yellow:
			sprite.frames = FRAMES_RECOLORABLE
			sprite.self_modulate = shine_color
	else:
		sprite.frames = FRAMES_COLLECTED
	
	sprite.play("default")
	outline.play("default")
	
	if is_hidden:
		shine.hint_tooltip = "???"
	else:
		shine.hint_tooltip = shine_dictionary.get("title", "Unknown Shine")
		shine.hint_tooltip += "\n"
		
		if time_score == -1:
			shine.hint_tooltip += "--:--.--"
		else:
			shine.hint_tooltip += LevelInfo.generate_time_string(time_score)
		
	shines.add_child(shine)


func add_star_coin(is_collected: bool):
	var star_coin: Control = STAR_COIN_SCENE.instance()
	var sprite: AnimatedSprite = star_coin.get_node("AnimatedSprite")
	if not is_collected:
		sprite.frames = COIN_FRAMES_COLLECTED
	sprite.play("default")
	star_coins.add_child(star_coin)
