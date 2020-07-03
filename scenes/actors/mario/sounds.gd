extends Node

onready var jump_sounds = $JumpSounds
onready var double_jump_sounds = $DoubleJumpSounds
onready var triple_jump_sounds = $TripleJumpSounds
onready var dive_sounds = $DiveSounds
onready var fall_sounds = $FallSounds
onready var hit_sounds = $HitSounds
onready var last_hit_sounds = $LastHitSounds
onready var death_sounds = $DeathSounds
onready var stomped_sounds = $StompedSounds

onready var gp_hit = $OtherSounds/GPHit
onready var gp_windup = $OtherSounds/GPWindup
onready var skid = $OtherSounds/Skid
onready var jump_voiceless = $OtherSounds/Jump
onready var double_jump_voiceless = $OtherSounds/DoubleJump
onready var triple_jump_voiceless = $OtherSounds/TripleJump
onready var wall_jump_voiceless = $OtherSounds/WallJump
onready var spin_sound = $OtherSounds/Spin
onready var duck_sound = $OtherSounds/Duck

onready var footsteps_default = $Footsteps/Default

var ready = false

# This code just plain sucks

func _ready():
	yield(get_tree().create_timer(0.1), "timeout")
	ready = true

func play_footsteps():
	if ready:
		footsteps_default.play()

func play_jump_sound():
	if ready:
		jump_sounds.play()
		jump_voiceless.play()

func play_double_jump_sound():
	if ready:
		double_jump_sounds.play()
		double_jump_voiceless.play()

func play_triple_jump_sound():
	if ready:
		triple_jump_sounds.play()
		triple_jump_voiceless.play()
		
func play_wall_jump_sound():
	if ready:
		jump_sounds.play()
		wall_jump_voiceless.play()
	
func play_dive_sound():
	if ready:
		dive_sounds.play()
	
func play_fall_sound():
	if ready:
		fall_sounds.play()
		
func play_last_hit_sound():
	if ready:
		last_hit_sounds.play()
	
func play_hit_sound():
	if ready:
		hit_sounds.play()

func play_death_sound():
	if ready:
		death_sounds.play()
	
func play_bonk_sound():
	if ready:
		hit_sounds.play()

func play_gp_windup_sound():
	if ready:
		gp_windup.play()

func play_gp_hit_sound():
	if ready:
		gp_hit.play()
	
func set_skid_playing(value):
	if ready:
		skid.playing = value
		
func play_duck_sound():
	if ready:
		duck_sound.play()

func play_spin_sound():
	if ready:
		spin_sound.play()
