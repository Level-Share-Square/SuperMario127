extends Control

onready var label = $Label
onready var label_shadow = $LabelShadow
onready var tween = $Tween

var last_shard_amount := 0

export var collected_height : float
var normal_height : float

var time_until_fall = 0.0
var max_shard_amount = 0

func _ready():
	normal_height = label.rect_position.y
	# warning-ignore: unused_variable
	for index in range(5):
		yield(get_tree(), "idle_frame")
	max_shard_amount = CurrentLevelData.level_data.vars.max_shine_shards
	var shard_amount = CurrentLevelData.level_data.vars.shine_shards_collected
	label.text = str(shard_amount) + "/" + str(max_shard_amount)
	label_shadow.text = label.text
	if max_shard_amount != 0:
		visible = true
	if CurrentLevelData.level_data.vars.max_red_coins == 0:
		rect_position.y = get_node("../RedCoinCounter").rect_position.y

func _process(delta):
	var shard_amount = CurrentLevelData.level_data.vars.shine_shards_collected
	if shard_amount != last_shard_amount:
		label.text = str(shard_amount) + "/" + str(max_shard_amount)
		label_shadow.text = label.text
		
		tween.interpolate_property(label, "rect_position",
			label.rect_position, Vector2(label.rect_position.x, collected_height), 0.075,
			Tween.TRANS_CIRC, Tween.EASE_OUT)
		tween.start()
		time_until_fall = 0.1
	last_shard_amount = shard_amount
	
	max_shard_amount = CurrentLevelData.level_data.vars.max_shine_shards
	
	label_shadow.rect_position = label.rect_position + Vector2(2, 2)

	if time_until_fall > 0:
		time_until_fall -= delta
		if time_until_fall <= 0:
			time_until_fall = 0
			tween.interpolate_property(label, "rect_position",
				label.rect_position, Vector2(label.rect_position.x, normal_height), 0.15,
				Tween.TRANS_BOUNCE, Tween.EASE_IN)
			tween.start()
