extends Node
onready var voice_effects = $VoiceEffects
onready var jump_sounds = $VoiceEffects/JumpSounds
onready var double_jump_sounds = $VoiceEffects/DoubleJumpSounds
onready var triple_jump_sounds = $VoiceEffects/TripleJumpSounds
onready var dive_sounds = $VoiceEffects/DiveSounds
onready var fall_sounds = $VoiceEffects/FallSounds
onready var hit_sounds = $VoiceEffects/HitSounds
onready var last_hit_sounds = $VoiceEffects/LastHitSounds
onready var death_sounds = $VoiceEffects/DeathSounds
onready var stomped_sounds = $VoiceEffects/StompedSounds
onready var powerup_sounds = $VoiceEffects/PowerupSounds
onready var lava_hurt_sounds = $VoiceEffects/LavaHurtSounds
onready var shine_sounds = $VoiceEffects/ShineSounds

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
onready var burn_sound = $OtherSounds/Burn

onready var footsteps_default = $Footsteps/Default
onready var footsteps_metal = $Footsteps/Metal



export var normal_bus : String
export var metal_bus : String
var ready = false
var last_metal_filter = true
var character = null

# This code used to suck. I doesn't anymore. I hope.

func _ready():
	#yield(get_tree().create_timer(0.1), "timeout") #this doesn't seem to do anything except cause an error? this is why you comment code
	if is_instance_valid(character):
		if character.metal_voice: #Is there more to change?
			voice_effects.set_bus(metal_bus)
		elif !character.metal_voice:
			voice_effects.set_bus(normal_bus)

	ready = true
	character = get_parent()

func play_footsteps():
	if ready:
		if character.metal_voice:
			footsteps_metal.play()
		else:
			footsteps_default.play()

func play_lava_hurt_sound():
	if ready:
		yield(get_tree().create_timer(0.04), "timeout")
		lava_hurt_sounds.play()

func play_burn_sound():
	if ready:
		burn_sound.play()

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
