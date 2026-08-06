extends VBoxContainer


onready var capsule = $"%Capsule"
onready var header = $"%Header"
onready var discord_banner = $"%DiscordBanner"
onready var discord_invite = $"%DiscordInvite"
onready var splash_screen = $"%SplashScreen"
onready var icon = $"%Icon"

func _ready():
	return
	
	for i in range(5):
		yield(get_tree(), "idle_frame")
		
	var capsule_img: Image = capsule.get_node("Viewport").get_texture().get_data()
	capsule_img.flip_y()
	capsule_img.save_png("res://assets/artwork/steam/capsule.png")

	var header_img: Image = header.get_node("Viewport").get_texture().get_data()
	header_img.flip_y()
	header_img.save_png("res://assets/artwork/steam/header.png")

	var discord_banner_img: Image = discord_banner.get_node("Viewport").get_texture().get_data()
	discord_banner_img.flip_y()
	discord_banner_img.save_png("res://assets/artwork/discord/banner.png")

	var discord_inv_img: Image = discord_invite.get_node("Viewport").get_texture().get_data()
	discord_inv_img.flip_y()
	discord_inv_img.save_png("res://assets/artwork/discord/invite_bg.png")

	var splash_img: Image = splash_screen.get_node("Viewport").get_texture().get_data()
	splash_img.flip_y()
	splash_img.save_png("res://assets/artwork/splash_screen.png")

	var icon_img: Image = icon.get_node("Viewport").get_texture().get_data()
	icon_img.flip_y()
	icon_img.save_png("res://assets/artwork/icon.png")
