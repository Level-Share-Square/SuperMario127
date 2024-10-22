class_name LSSLevelInfo

var level_id: String
var level_name: String
var thumbnail_url: String

var author_name: String
var tags: PoolStringArray

var rating: float
var rates: int

var favorites: int
var plays: int
var comments: int

var has_played: bool
var has_rated: bool


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
	level_name = fetch(data, "name")
	thumbnail_url = fetch(data, "thumbnail")
	
	author_name = fetch(fetch(data, "author", {}), "username")
	tags = PoolStringArray(fetch(data, "tags", []))
	
	rating = float(fetch(data, "rating"))
	rates = int(fetch(data, "raters"))
	
	favorites = int(fetch(data, "favourites"))
	plays = int(fetch(data, "plays"))
	comments = fetch(data, "commenters", []).size()
	
	has_played = fetch(data, "hasPlayed", false)
	has_rated = fetch(data, "hasRated", false)
	
	print(data)
