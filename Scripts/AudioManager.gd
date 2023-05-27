extends Node
var footsteps_on_wood_wav = preload("res://Sounds/FootstepsOnWood.wav")
var footsteps_on_concrete_wav = preload("res://Sounds/FootstepsOnConcrete.wav")
var jump_land_wav= preload("res://Sounds/JumpLand.wav")

var sound_map := {
	"Wood": Surface.new(
		5, 
		10, 
		footsteps_on_wood_wav, 
		jump_land_wav,
		footsteps_on_wood_wav
	),
	"Concrete": Surface.new(
		6, 
		12, 
		footsteps_on_concrete_wav, 
		jump_land_wav,
		footsteps_on_concrete_wav
	)
}
