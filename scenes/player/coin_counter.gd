extends Control

onready var label = $Label
onready var label_shadow = $LabelShadow

var last_coin_amount := 0

func _process(delta):
	var coin_amount = CurrentLevelData.level_data.vars.coins_collected
	if coin_amount != last_coin_amount:
		label.text = str(coin_amount).pad_zeros(2)
		label_shadow.text = label.text
	last_coin_amount = coin_amount
