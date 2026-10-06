extends VBoxContainer

const HIDDEN_TITLE: String = "???"

const SHINE_SCENE: PackedScene = preload("res://scenes/menu/pause/shine_map/shine.tscn")

const FRAMES_NORMAL: Resource = preload("res://scenes/actors/objects/shine/frames_normal.tres")
const FRAMES_RECOLORABLE: Resource = preload("res://scenes/actors/objects/shine/frames_recolorable.tres")
const FRAMES_COLLECTED: Resource = preload("res://scenes/actors/objects/shine/frames_collected.tres")

const FRAMES_POCKET: Resource = preload("res://scenes/actors/objects/shine/frames_pocket.tres")
const FRAMES_POCKET_RECOLORABLE: Resource = preload("res://scenes/actors/objects/shine/frames_pocket_recolorable.tres")
const FRAMES_POCKET_COLLECTED: Resource = preload("res://scenes/actors/objects/shine/frames_pocket_collected.tres")

const STAR_COIN_SCENE: PackedScene = preload("res://scenes/menu/pause/shine_map/star_coin.tscn")
const COIN_FRAMES_COLLECTED: SpriteFrames = preload("res://scenes/actors/objects/star_coin/collected_frames.tres")

onready var title = $"%Title"
onready var shines = $"%Shines"
onready var star_coins = $"%StarCoins"

var collectible_display: Label
var collectible_star: Control
var time_separator: HSeparator
var time_display: Label

var level_metadata: LevelMetadata
var level_save_data: LevelSaveData


func _ready():
	populate()

func populate() -> void:
	var is_hidden: bool = false
	
	var collected_shines: Array = level_save_data._completed_missions
	var collected_star_coins: Array = level_save_data._collected_star_coins
	if collected_shines.count(true) <= 0 and collected_star_coins.count(true) <= 0:
		is_hidden = true
	title.text = HIDDEN_TITLE if is_hidden else level_metadata.level_name
	
	var missions: Array = []
	var collectible_data: CollectibleData = level_metadata.collectible_data
	for mission_uuid in collectible_data.used_mission_data:
		missions.append(collectible_data.get_mission_by_uuid(mission_uuid))
	
	missions.sort_custom(MissionData, "sort_by_order")
	
	for mission_data in missions:
		add_shine(
			level_save_data.is_mission_complete(mission_data.mission_uuid), 
			mission_data,
			level_save_data.get_time_score(mission_data.mission_uuid), 
			is_hidden
		)
	
	var star_coin_index: int = 0
	for star_coin_data in collectible_data.star_coin_data:
		add_star_coin(
			level_save_data.is_star_coin_collected(star_coin_data.star_coin_uuid), 
			star_coin_data,
			star_coin_index
		)
		star_coin_index += 1


func add_shine(is_collected: bool, mission_data: MissionData, time_score: int, is_hidden: bool):
	var shine: Control = SHINE_SCENE.instance()
	var sprite: AnimatedSprite = shine.get_node("AnimatedSprite")
	var recolorable: AnimatedSprite = shine.get_node("AnimatedSprite/Recolorable")
	var do_kick_out: bool = mission_data.shine_force_leave
	
	if is_collected:
		sprite.frames = FRAMES_NORMAL if do_kick_out else FRAMES_POCKET
		var shine_color: Color = mission_data.shine_color
		if shine_color != Color.yellow:
			recolorable.frames = FRAMES_RECOLORABLE if do_kick_out else FRAMES_POCKET_RECOLORABLE
			recolorable.self_modulate = shine_color
			recolorable.show()
	else:
		sprite.frames = FRAMES_COLLECTED if do_kick_out else FRAMES_POCKET_COLLECTED
	
	sprite.flip_h = not do_kick_out
	sprite.play("default")
	recolorable.play("default")
	
	var display_text: String = mission_data.shine_name if not is_hidden else "???"
	shine.connect("hovered", self, "update_display", [display_text, is_collected, true, time_score])
	shines.add_child(shine)


func add_star_coin(is_collected: bool, star_coin_data: StarCoinData, star_coin_index: int):
	var star_coin: Control = STAR_COIN_SCENE.instance()
	
	var sprite: AnimatedSprite = star_coin.get_node("AnimatedSprite")
	if not is_collected:
		sprite.frames = COIN_FRAMES_COLLECTED
	sprite.play("default")
	
	star_coin.connect("hovered", self, "update_display", ["Star Coin %s" % str(star_coin_index + 1), is_collected])
	star_coins.add_child(star_coin)


func update_display(name_text: String, is_collected, has_time: bool = false, time_score: int = -1):
	if has_time:
		time_separator.show()
		time_display.show()
		if time_score == -1:
			time_display.text = "--:--.--"
		else:
			time_display.text = LevelInfo.generate_time_string(time_score)
	else:
		time_separator.hide()
		time_display.hide()
	
	collectible_display.text = name_text
	collectible_star.visible = is_collected
