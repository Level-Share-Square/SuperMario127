extends Control

export var list_handler_path: NodePath
onready var list_handler: Node = get_node(list_handler_path)
var level_id: String

### info
onready var title := $Info/Title
onready var title_shadow := $Info/Title/Shadow

export var author_prefix: String = "by "
onready var author := $Info/Author

onready var description := $Panel/MarginContainer/Description


onready var shine_label := $Info/Shines/Label
onready var star_coin_label := $Info/StarCoins/Label

export var completion_color: Color = Color("e9adff")
onready var percentage_label := $Info/Completion/Percentage

func load_level_info(level_info: LevelInfo, _level_id: String):
	level_id = _level_id
	
	title.text = level_info.level_name
	title_shadow.text = title.text
	
	author.text = author_prefix + level_info.level_author
	description.bbcode_text = level_info.level_description
	
	
	
	var shine_amount: int = level_info.shine_details.size()
	var star_coin_amount: int = level_info.star_coin_details.size()
	
	var shine_collected_amount: int = level_info.collected_shines.size()
	var star_coin_collected_amount: int = level_info.collected_star_coins.size()
	
	shine_label.text = str(shine_collected_amount) + "/" + str(shine_amount)
	shine_label.modulate = completion_color if (shine_collected_amount >= shine_amount) else Color.white
	star_coin_label.text = str(star_coin_collected_amount) + "/" + str(star_coin_amount)
	star_coin_label.modulate = completion_color if (star_coin_collected_amount >= star_coin_amount) else Color.white
	
	
	
	# these are floats cuz they need to be divided for some calculations :)
	var total_collectibles: float = shine_amount + star_coin_amount
	var total_collected: float = shine_collected_amount + star_coin_collected_amount
	if total_collectibles <= 0: 
		percentage_label.text = "100%"
		percentage_label.modulate = completion_color
		return # OTHERWISE THE UNIVERSE WILL EXPLODEEEE ZOMG
	
	var completion_percent: float = stepify(total_collected / total_collectibles, 0.01) * 100
	percentage_label.modulate = completion_color if (completion_percent >= 100) else Color.white
	percentage_label.text = str(completion_percent) + "%"

func delete_level():
	list_handler.remove_level(level_id)
