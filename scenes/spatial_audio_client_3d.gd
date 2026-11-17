@icon("res://addons/at-icons/node3d/speech_bubble_exclamation.svg")
class_name SpatialAudioClient3D extends Node3D

func play_sound(sound_effect: SoundEffect, follow_node: Node3D = null) -> void:
	var target: Node3D = follow_node if follow_node else self
	AudioManager.play_spatial_sound_3d(sound_effect, target)
