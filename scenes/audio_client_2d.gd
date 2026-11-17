@icon("res://addons/at-icons/node2d/speech_bubble_ellipsis.svg")
class_name AudioClient2D extends Node2D

func play_sound(sound_effect: SoundEffect, follow_node: Node2D = null) -> void:
	var target: Node2D = follow_node if follow_node else self
	AudioManager.play_sound_2d(sound_effect, target)
