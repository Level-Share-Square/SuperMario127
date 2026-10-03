extends ButtonHoverVertical

func _ready():
	toggled(pressed)

func toggled(button_pressed: bool):
	$Orb.region_rect.position.x = 16 if button_pressed else 0
