class_name LSSLevelPage


var level_id: String
var level_code: String
var level_info: LevelInfo

var level_name: String
var thumbnail_url: String
var timestamp: String

var author_name: String
var author_icon_url: String

var description: String
var tags: PoolStringArray

var rating: float
var rates: int

var favorites: int
var plays: int
var comments: int

var has_played: bool
var has_rated: float


## dictionary.value causes errors, if the data happens
## not to have the required value.
## and pure dictionary.get() just ends up being wordy with all the
## empty string parameters...
func fetch(dictionary: Dictionary, key: String, default = ""):
	var value = dictionary.get(key, default)
	if value == null and default != null: 
		value = default
	return value 


func _init(data: Dictionary):
	level_id = fetch(data, "_id")
	level_code = fetch(data, "code")
	
	level_name = fetch(data, "name")
	thumbnail_url = fetch(data, "thumbnail")
	timestamp = fetch(data, "postDate")
	
	author_name = fetch(fetch(data, "author", {}), "username")
	author_icon_url = fetch(fetch(data, "author", {}), "avatar")
	
	description = fetch(data, "description")
	tags = PoolStringArray(fetch(data, "tags", []))
	
	rating = float(fetch(data, "rating", 0))
	rates = int(fetch(data, "raters", 0))
	
	favorites = int(fetch(data, "favourites", 0))
	plays = int(fetch(data, "plays", 0))
	comments = fetch(data, "commenters", []).size()
	
	has_played = fetch(data, "hasPlayed", false)
	has_rated = fetch(data, "hasRated", 0)
	
	level_info = LevelInfo.new("", "", level_code)
	
#	data.erase("code")
#	print(data)
