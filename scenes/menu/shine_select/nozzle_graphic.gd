tool
extends PanelContainer


enum BoxType {
	Empty,
	Hover,
	Rocket,
	Turbo
}

onready var icon = $"%Icon"
onready var inner_panel = $"%InnerPanel"
onready var shine = $"%Shine"
onready var tween = $"%Tween"

export var panel_empty: StyleBox
export var panel_hover: StyleBox
export var panel_rocket: StyleBox
export var panel_turbo: StyleBox

export var inner_panel_empty: StyleBox
export var inner_panel_hover: StyleBox
export var inner_panel_rocket: StyleBox
export var inner_panel_turbo: StyleBox

export var shine_empty: Texture
export var shine_hover: Texture
export var shine_rocket: Texture
export var shine_turbo: Texture

export var color_empty: Color
export var color_hover: Color
export var color_rocket: Color
export var color_turbo: Color

export(BoxType) var box_type: int


func _ready():
	var suffix: String
	match box_type:
		BoxType.Empty:
			suffix = "empty"
		BoxType.Hover:
			suffix = "hover"
		BoxType.Rocket:
			suffix = "rocket"
		BoxType.Turbo:
			suffix = "turbo"
	
	add_stylebox_override("panel", self["panel_%s" % suffix])
	inner_panel.add_stylebox_override("panel", self["inner_panel_%s" % suffix])
	icon.modulate = self["color_%s" % suffix]
	shine.texture = self["shine_%s" % suffix]


func animate():
	rect_scale *= 1.1
	modulate *= 1.25
	modulate.a = 1.0
	tween.stop_all()
	tween.interpolate_property(self, "rect_scale", rect_scale, Vector2.ONE, 0.2, Tween.TRANS_CIRC, Tween.EASE_IN)
	tween.interpolate_property(self, "modulate", modulate, Color.white, 0.2, Tween.TRANS_CIRC, Tween.EASE_IN)
	tween.start()
