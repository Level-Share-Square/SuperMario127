extends HBoxContainer

onready var http_images = $"%HTTPImages"
onready var account_info = $"%AccountInfo"

onready var icon = $Icon
onready var username = $Control/Name


func load_profile():
	username.text = account_info.username
	if account_info.icon_url != "":
		yield(get_tree(), "idle_frame")
		http_images.connect("image_loaded", self, "image_loaded")
		http_images.image_queue.append(account_info.icon_url)
		http_images.load_next_image()


func image_loaded(url: String, texture: ImageTexture):
	if texture == null: return
	if url != account_info.icon_url: return
	icon.texture = texture
	http_images.disconnect("image_loaded", self, "image_loaded")
