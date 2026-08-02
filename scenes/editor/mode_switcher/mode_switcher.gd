extends CanvasLayer


const HOVER_TRANS: int = Tween.TRANS_QUAD
const HOVER_EASE: int = Tween.EASE_OUT

onready var root_container: MarginContainer = $"%RootContainer"
onready var top_inner: PanelContainer = $"%TopInner"
onready var bottom_inner: PanelContainer = $"%BottomInner"
onready var mario_front: AnimatedSprite = $"%MarioFront"
onready var mario_back: AnimatedSprite = $"%MarioBack"

onready var tween: Tween = $"%Tween"
onready var tween_press: Tween = $"%TweenPress"

export var bottom_height: float
export var bottom_height_hover: float
export var hover_duration: float

export var mario_idle_height: float
export var mario_hidden_height: float
export var mario_enter_height: float
export var mario_exit_height: float

export var mario_enter_jump_time: float
export var mario_enter_fall_time: float


func hovered() -> void:
	tween.stop_all()
	tween.interpolate_property(
		bottom_inner,
		"rect_min_size:y",
		bottom_inner.rect_min_size.y,
		bottom_height_hover,
		hover_duration,
		HOVER_TRANS,
		HOVER_EASE
	)
	tween.interpolate_property(
		mario_front,
		"modulate:a",
		mario_front.modulate.a,
		1.0,
		hover_duration,
		HOVER_TRANS,
		HOVER_EASE
	)
	tween.interpolate_property(
		mario_back,
		"modulate:a",
		mario_back.modulate.a,
		1.0,
		hover_duration,
		HOVER_TRANS,
		HOVER_EASE
	)
	tween.start()


func unhovered() -> void:
	tween.stop_all()
	tween.interpolate_property(
		bottom_inner,
		"rect_min_size:y",
		bottom_inner.rect_min_size.y,
		bottom_height,
		hover_duration,
		HOVER_TRANS,
		HOVER_EASE
	)
	tween.interpolate_property(
		mario_front,
		"modulate:a",
		mario_front.modulate.a,
		0.5,
		hover_duration,
		HOVER_TRANS,
		HOVER_EASE
	)
	tween.interpolate_property(
		mario_back,
		"modulate:a",
		mario_back.modulate.a,
		0.5,
		hover_duration,
		HOVER_TRANS,
		HOVER_EASE
	)
	tween.start()


func pressed() -> void:
	root_container.mouse_filter = Control.MOUSE_FILTER_STOP
	
	mario_front.show_behind_parent = false
	mario_front.play("enter")
	mario_back.play("enter")
	
	tween_press.stop_all()
	tween_press.interpolate_property(
		mario_front,
		"position:y",
		mario_front.position.y,
		mario_enter_height,
		mario_enter_jump_time,
		Tween.TRANS_QUART,
		Tween.EASE_OUT
	)
	tween_press.interpolate_property(
		mario_back,
		"position:y",
		mario_back.position.y,
		mario_enter_height,
		mario_enter_jump_time,
		Tween.TRANS_QUART,
		Tween.EASE_OUT
	)
	tween_press.start()
	
	yield(tween_press, "tween_all_completed")
	
	mario_front.show_behind_parent = true
	tween_press.interpolate_property(
		mario_front,
		"position:y",
		mario_front.position.y,
		mario_hidden_height,
		mario_enter_fall_time,
		Tween.TRANS_QUART,
		Tween.EASE_IN
	)
	tween_press.interpolate_property(
		mario_back,
		"position:y",
		mario_back.position.y,
		mario_hidden_height,
		mario_enter_fall_time,
		Tween.TRANS_QUART,
		Tween.EASE_IN
	)
	tween_press.start()
	
	yield(tween_press, "tween_all_completed")
	root_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
