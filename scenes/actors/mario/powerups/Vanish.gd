extends Powerup 
class_name VanishPowerup 

func _ready():
    music_id = 25 #temporary, replace with proper vanish cap music later

func apply_visuals():
    character.sprite.material = material 

func remove_visuals():
    character.sprite.material = null 

func toggle_visuals():
	if character.sprite.material == null:
		apply_visuals()
	else:
		remove_visuals()