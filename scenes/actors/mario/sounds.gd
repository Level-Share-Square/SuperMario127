extends Node

onready var jump_sounds = $JumpSounds
onready var double_jump_sounds = $DoubleJumpSounds
onready var triple_jump_sounds = $TripleJumpSounds
onready var dive_sounds = $DiveSounds
onready var fall_sounds = $FallSounds
onready var hit_sounds = $HitSounds
onready var stomped_sounds = $StompedSounds

func play_jump_sound():
	jump_sounds.play()

func play_double_jump_sound():
	double_jump_sounds.play()

func play_triple_jump_sound():
	triple_jump_sounds.play()
	
func play_dive_sound():
	dive_sounds.play()
	
func play_fall_sound():
	fall_sounds.play()
	
func play_hit_sound():
	hit_sounds.play()
