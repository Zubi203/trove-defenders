class_name AudioComponent
extends AudioStreamPlayer2D

@export var pitch_variation: float = 0.3

func play_sound(sound: AudioStream):
	if sound == null:
		return
	stream = sound
	play()

func play_sound_random_pitch(sound: AudioStream):
	var base_pitch = pitch_scale
	pitch_scale = randf_range(base_pitch - pitch_variation, base_pitch + pitch_variation)
	play_sound(sound)
	pitch_scale = base_pitch
