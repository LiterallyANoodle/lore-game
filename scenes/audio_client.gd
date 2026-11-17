@icon("res://addons/at-icons/node/speech_bubble_ellipsis.svg")
class_name AudioClient extends Node

func play_sound(sound_effect: SoundEffect) -> void:
	AudioManager.play_sound(sound_effect)
