extends AnimatedSprite

onready var tween = $Tween
onready var tween2 = $Tween2
onready var file = File.new()
var ghost_pos
var ghost_anim
var ghost_rotation
var frame_counter = -1
var sfc = 0
var play_ghost = false
const ANIM_IDS : Array = [
	"x",
	"armsOut",
	"bonkedLeft",
	"bonkedRight",
	"death", 
	"deathFall", 
	"diveLeft", 
	"diveRight",
	"doubleFallLeft",
	"doubleFallRight",
	"doubleJumpLeft", 
	"doubleJumpRight", 
	"enterDoorLeft", 
	"enterDoorRight", 
	"exitDoorLeft", 
	"exitDoorRight", 
	"fallLeft", 
	"fallRight", 
	"flyLeft", 
	"flyRight", 
	"groundPoundEndLeft", 
	"groundPoundEndRight", 
	"groundPoundLeft", 
	"groundPoundRight",
	"idleLeft",
	"idleRight",
	"jumpLeft",
	"jumpRight",
	"lavaBoost",
	"movingIn", 
	"movingLeft",
	"movingOut",
	"movingRight", 
	"pipeExitLeft", 
	"pipeExitRight",
	"pipeLeft",
	"pipeRight",
	"shineDance", 
	"shineFall",
	"spinning", 
	"starRunLeft", 
	"starRunRight", 
	"swimming",
	"tripleJumpLeft",
	"tripleJumpRight",
	"wallSlideLeft",
	"wallSlideRight",
]

func _ready():
	var level_info = Singleton.SavedLevels.get_current_levels()[Singleton.SavedLevels.selected_level]
	if file.file_exists("user://replays/" + str(level_info.level_name) + "_" + str(level_info.selected_shine) + ".127ghost"):
		play_ghost = true

func _physics_process(delta):
	var level_info = Singleton.SavedLevels.get_current_levels()[Singleton.SavedLevels.selected_level]
	if Singleton2.ghost_enabled:
		if play_ghost:
			file.open("user://replays/" + str(level_info.level_name) + "_" + str(level_info.selected_shine) + ".127ghost", File.READ)
			ghost_pos = file.get_var()
			ghost_anim = file.get_var()
			ghost_rotation = file.get_var()
			file.close()
			if frame_counter < ghost_anim.size() - 2:
				frame_counter += 1
			animation = ANIM_IDS[ghost_anim[frame_counter]]
			rotation_degrees = ghost_rotation[frame_counter]
			position = ghost_pos[frame_counter]
