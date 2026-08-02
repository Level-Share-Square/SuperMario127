extends CanvasLayer


const COLOR_TRANS: int = Tween.TRANS_CIRC
const COLOR_EASE: int = Tween.EASE_IN
const COLOR_DELAY: float = 0.5

onready var button: Button = $"%Button"
onready var top_inner: PanelContainer = $"%TopInner"
onready var bottom_inner: PanelContainer = $"%BottomInner"
onready var grid_overlay_1 = $"%GridOverlay1"
onready var grid_overlay_2 = $"%GridOverlay2"
onready var mario_front: AnimatedSprite = $"%MarioFront"
onready var pipe_sound: AudioStreamPlayer = $"%PipeSound"
onready var letsa_go_sfx = $"%LetsaGo"

onready var tween: Tween = $"%Tween"
onready var transition_player = $"%TransitionPlayer"
onready var animation_player = $"%AnimationPlayer"
onready var transition_rect = $"%TransitionRect"

export var grid_color_green: Color
export var grid_color_red: Color
export var pipe_gradient_tex_base: GradientTexture2D
export var pipe_gradient_green: Gradient
export var pipe_gradient_red: Gradient
export var pipe_flash_gradient_tex_base: GradientTexture2D
export var pipe_flash_gradient_green: Gradient
export var pipe_flash_gradient_red: Gradient

export var color_change_duration: float

var is_hovered: bool
var is_switching: bool
var is_transitioning_to_red: bool
## TEMP
var TEMP_MODE_SWITCHED: bool = false


func hovered() -> void:
	is_hovered = true
	if is_switching: return
	animation_player.play("hover_marioless" if TEMP_MODE_SWITCHED else "hover")


func unhovered() -> void:
	is_hovered = false
	if is_switching: return
	animation_player.play_backwards("hover_marioless" if TEMP_MODE_SWITCHED else "hover")


func pressed() -> void:
	transition_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	is_switching = true
	button.disabled = true
	
	if not TEMP_MODE_SWITCHED:
		letsa_go_sfx.play()
	
	# pipe color tweens
	is_transitioning_to_red = not TEMP_MODE_SWITCHED
	tween.interpolate_property(
		grid_overlay_1,
		"modulate",
		grid_overlay_1.modulate,
		grid_color_red if is_transitioning_to_red else grid_color_green,
		color_change_duration,
		COLOR_TRANS,
		COLOR_EASE,
		COLOR_DELAY
	)
	tween.interpolate_property(
		grid_overlay_2,
		"modulate",
		grid_overlay_2.modulate,
		grid_color_red if is_transitioning_to_red else grid_color_green,
		color_change_duration,
		COLOR_TRANS,
		COLOR_EASE,
		COLOR_DELAY
	)
	tween.interpolate_method(
		self,
		"interpolate_gradient",
		0.0,
		1.0,
		color_change_duration,
		COLOR_TRANS,
		COLOR_EASE,
		COLOR_DELAY
	)
	tween.start()
	
	if not TEMP_MODE_SWITCHED:
		animation_player.play("press")
		yield(animation_player, "animation_finished")
		if not is_hovered:
			animation_player.play_backwards("hover_marioless")
	
	transition_player.play("transition_in")
	yield(transition_player, "animation_finished")
	
	if TEMP_MODE_SWITCHED:
		animation_player.play("exit")
		yield(animation_player, "animation_finished")
		if not is_hovered:
			animation_player.play_backwards("hover")
	
	TEMP_MODE_SWITCHED = not TEMP_MODE_SWITCHED
	transition_player.play("transition_out")
	yield(transition_player, "animation_finished")
	
	transition_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	is_switching = false
	button.disabled = false


func interpolate_gradient(weight: float) -> void:
	var gradient_tex_bases: Array = [
		pipe_gradient_tex_base,
		pipe_flash_gradient_tex_base
	]
	var gradient_origins: Array = [
		pipe_gradient_red,
		pipe_flash_gradient_red
	]
	var gradient_targets: Array = [
		pipe_gradient_green,
		pipe_flash_gradient_green
	]
	
	if is_transitioning_to_red:
		var swap: Array = gradient_targets
		gradient_targets = gradient_origins
		gradient_origins = swap
	
	for gradient_index in range(gradient_tex_bases.size()):
		var gradient_origin: Gradient = gradient_origins[gradient_index]
		var gradient_target: Gradient = gradient_targets[gradient_index]
		for color_index in range(gradient_origin.colors.size()):
			var color_a: Color = gradient_origin.colors[color_index]
			var color_b: Color = gradient_target.colors[color_index]
			var blended_color: Color = color_a.linear_interpolate(color_b, weight)
			gradient_tex_bases[gradient_index].gradient.set_color(color_index, blended_color)
			
