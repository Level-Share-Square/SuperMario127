extends VBoxContainer


onready var capsule = $"%Capsule"
onready var header = $"%Header"
onready var discord_header = $"%DiscordHeader"
onready var discord_banner = $"%DiscordBanner"
onready var discord_invite = $"%DiscordInvite"
onready var youtube_banner = $"%YoutubeBanner"
onready var bluesky_banner = $"%BlueskyBanner"
onready var splash_screen = $"%SplashScreen"
onready var icon = $"%Icon"
onready var twitter_icon = $"%TwitterIcon"
onready var end_cards = $"%EndCards"
onready var shorts_template = $"%ShortsTemplate"
onready var coin_hud = $"%CoinHUD"

func _ready():
	#return
	
	for i in range(5):
		yield(get_tree(), "idle_frame")
		
#	var capsule_img: Image = capsule.get_node("Viewport").get_texture().get_data()
#	capsule_img.flip_y()
#	capsule_img.save_png("res://assets/artwork/steam/capsule.png")
#
#	var header_img: Image = header.get_node("Viewport").get_texture().get_data()
#	header_img.flip_y()
#	header_img.save_png("res://assets/artwork/steam/header.png")
#
#	var discord_header_img: Image = discord_header.get_node("Viewport").get_texture().get_data()
#	discord_header_img.flip_y()
#	discord_header_img.save_png("res://assets/artwork/discord/header.png")
#
#	var discord_banner_img: Image = discord_banner.get_node("Viewport").get_texture().get_data()
#	discord_banner_img.flip_y()
#	discord_banner_img.save_png("res://assets/artwork/discord/banner.png")
#
#	var discord_inv_img: Image = discord_invite.get_node("Viewport").get_texture().get_data()
#	discord_inv_img.flip_y()
#	discord_inv_img.save_png("res://assets/artwork/discord/invite_bg.png")
#
#	var youtube_banner_img: Image = youtube_banner.get_node("Viewport").get_texture().get_data()
#	youtube_banner_img.flip_y()
#	youtube_banner_img.save_png("res://assets/artwork/youtube/banner.png")
#
#	var bluesky_banner_img: Image = bluesky_banner.get_node("Viewport").get_texture().get_data()
#	bluesky_banner_img.flip_y()
#	bluesky_banner_img.save_png("res://assets/artwork/bluesky/banner.png")

#	var splash_img: Image = splash_screen.get_node("Viewport").get_texture().get_data()
#	splash_img.flip_y()
#	splash_img.save_png("res://assets/artwork/splash_screen.png")

#	var icon_img: Image = icon.get_node("Viewport").get_texture().get_data()
#	icon_img.flip_y()
#	icon_img.save_png("res://assets/artwork/icon.png")
#
#	var twitter_icon_img: Image = twitter_icon.get_node("Viewport").get_texture().get_data()
#	twitter_icon_img.flip_y()
#	twitter_icon_img.save_png("res://assets/artwork/twitter/twitter_icon.png")
	
#	var shorts_template_img: Image = shorts_template.get_node("Viewport").get_texture().get_data()
#	shorts_template_img.convert(Image.FORMAT_RGBA8)
#	shorts_template_img.flip_y()
#	fix_transparency(shorts_template_img)
#	shorts_template_img.save_png("res://assets/artwork/youtube/shorts_template.png")

	var coin_hud_img: Image = coin_hud.get_node("Viewport").get_texture().get_data()
	coin_hud_img.convert(Image.FORMAT_RGBA8)
	coin_hud_img.flip_y()
	fix_transparency(coin_hud_img)
	coin_hud_img.save_png("res://assets/artwork/coin_hud.png")


func fix_transparency(image_data: Image) -> void:
	for j in image_data.get_height():
		for i in image_data.get_width():
			var c = image_data.get_pixel(i, j)
			if c.a > 0:
				c.r /= c.a
				c.g /= c.a
				c.b /= c.a
			image_data.set_pixel(i, j, c)
