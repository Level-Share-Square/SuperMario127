class_name StarCoinData
extends LevelDataResource


var star_coin_uuid: String
var star_coin_hint: String
var star_coin_color: Color


func _init(
		s_star_coin_uuid: String = uuid_util.v4(),
		s_star_coin_hint: String = "", 
		s_star_coin_color: Color = Color.white
	) -> void:
	star_coin_uuid = s_star_coin_uuid
	star_coin_hint = s_star_coin_hint
	star_coin_color = s_star_coin_color
