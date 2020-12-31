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
onready var powerup_sounds = $PowerupSounds
onready var shine_sounds = $ShineSounds

onready var gp_hit = $OtherSounds/GPHit
onready var gp_windup = $OtherSounds/GPWindup
onready var skid = $OtherSounds/Skid
onready var jump_voiceless = $OtherSounds/Jump
onready var double_jump_voiceless = $OtherSounds/DoubleJump
onready var triple_jump_voiceless = $OtherSounds/TripleJump
onready var wall_jump_voiceless = $OtherSounds/WallJump
onready var spin_sound = $OtherSounds/Spin
onready var duck_sound = $OtherSounds/Duck
onready var last_hit_8bit_sound = $OtherSounds/LastHit8Bit
onready var splash_sound = $OtherSounds/WaterSplash
onready var swim_sound = $OtherSounds/Swim
onready var spin_water_sound = $OtherSounds/SpinWater
onready var powerup_sound_voiceless = $OtherSounds/Powerup

onready var footsteps_default = $Footsteps/Default

export var voices_bus : String
export var metal_bus : String
var ready = false
var last_metal_filter = true
var character = null

# This code just plain sucks

func _ready():
	#yield(get_tree().create_timer(0.1), "timeout") #this doesn't seem to do anything except cause an error? this is why you comment code
	ready = true
	character = get_parent()
	
func switch_bus(node, bus):
	node.bus = bus
	
func _physics_process(_delta):
	if is_instance_valid(character):
		if character.metal_voice and !last_metal_filter: #peak of coding right here
			switch_bus(jump_sounds, metal_bus)
			switch_bus(double_jump_sounds, metal_bus)
			switch_bus(triple_jump_sounds, metal_bus)
			switch_bus(dive_sounds, metal_bus)
			switch_bus(fall_sounds, metal_bus)
			switch_bus(hit_sounds, metal_bus)
			switch_bus(last_hit_sounds, metal_bus)
			switch_bus(death_sounds, metal_bus)
			switch_bus(stomped_sounds, metal_bus)
			switch_bus(powerup_sounds, metal_bus)
			switch_bus(shine_sounds, metal_bus)
		elif !character.metal_voice and last_metal_filter:
			switch_bus(jump_sounds, voices_bus)
			switch_bus(double_jump_sounds, voices_bus)
			switch_bus(triple_jump_sounds, voices_bus)
			switch_bus(dive_sounds, voices_bus)
			switch_bus(fall_sounds, voices_bus)
			switch_bus(hit_sounds, voices_bus)
			switch_bus(last_hit_sounds, voices_bus)
			switch_bus(death_sounds, voices_bus)
			switch_bus(stomped_sounds, voices_bus)
			switch_bus(powerup_sounds, voices_bus)
			switch_bus(shine_sounds, voices_bus)
			
		last_metal_filter = character.metal_voice

func play_footsteps():
	if ready:
		footsteps_default.play()

func play_jump_sound():
	if ready:
		jump_sounds.play()
		jump_voiceless.play()

func play_jump_sound_voiceless():
	if ready:
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

func play_wall_jump_sound_voiceless():
	if ready:
		wall_jump_voiceless.play()
	
func play_dive_sound():
	if ready:
		dive_sounds.play()
	
func play_fall_sound():
	if ready:
		fall_sounds.play()
		
func play_last_hit_sound():
	if ready:
		last_hit_8bit_sound.play()
	
func play_hit_sound():
	if ready:
		hit_sounds.play()

func play_death_sound():
	if ready:
		death_sounds.play()

func play_powerup_sound():
	if ready:
		powerup_sounds.play()

func play_shine_sound():
	if ready:
		shine_sounds.play()

func play_powerup_jingle():
	if ready:
		powerup_sound_voiceless.play()
	
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

func play_spin_water_sound():
	if ready:
		spin_water_sound.play()

func play_splash_sound():
	if ready:
		splash_sound.play()

func set_swim_playing(value):
	if ready:
		swim_sound.playing = value
