class_name LSSComment


var content: String

var comment_id: String
var author_id: String
var author_name: String
var author_icon_url: String
var timestamp: String

var user_likes: PoolStringArray
var user_dislikes: PoolStringArray

var likes: int
var dislikes: int


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
	content = fetch(data, "content")
	
	comment_id = fetch(data, "_id")
	author_id = fetch(fetch(data, "author", {}), "_id")
	author_name = fetch(fetch(data, "author", {}), "username")
	author_icon_url = fetch(fetch(data, "author", {}), "avatar")
	timestamp = fetch(data, "postDate")
	
	user_likes = fetch(data, "user_likes", [])
	user_dislikes = fetch(data, "user_dislikes", [])
	
	likes = user_likes.size()
	dislikes = user_dislikes.size()
