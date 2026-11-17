@icon("res://addons/at-icons/node/speaker.svg")
extends Node

class AudioFollower:
	var audio_player: Node
	var follow_node: Node
	func _init(p_audio_player: Node, p_follow_node: Node) -> void:
		audio_player = p_audio_player
		follow_node = p_follow_node

const SPATIAL_AUDIO_PLAYER_SCENE: PackedScene = preload("res://addons/SpatialAudio/SpatialAudioPlayer3D.tscn")

var audio_followers: Array[AudioFollower] = []

func _process(_delta: float) -> void:
	for f: AudioFollower in audio_followers:
		if is_instance_valid(f.follow_node):
			f.audio_player.set("global_position", f.follow_node.get("global_position"))

func play_sound(sound: SoundEffect) -> AudioStreamPlayer:
	var new_player: AudioStreamPlayer = AudioStreamPlayer.new()
	self.add_child(new_player)
	new_player.stream = sound.stream
	new_player.volume_db = sound.volume_db
	new_player.bus = sound.bus
	new_player.finished.connect(new_player.queue_free)
	new_player.play()
	return new_player

func play_sound_2d(
		sound: SoundEffect, 
		follow_node: Node2D
	) -> AudioStreamPlayer2D:
	var new_player: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
	self.add_child(new_player)
	new_player.stream = sound.stream
	new_player.volume_db = sound.volume_db
	new_player.bus = sound.bus
	new_player.global_position = follow_node.global_position
	var follower: AudioFollower = AudioFollower.new(new_player, follow_node)
	audio_followers.append(follower)
	new_player.finished.connect(destroy_player.bind(follower))
	new_player.play()
	return new_player
	
func play_sound_3d(
		sound: SoundEffect, 
		follow_node: Node3D
	) -> AudioStreamPlayer3D:
	var new_player: AudioStreamPlayer3D = AudioStreamPlayer3D.new()
	self.add_child(new_player)
	new_player.stream = sound.stream
	new_player.volume_db = sound.volume_db
	new_player.bus = sound.bus
	new_player.global_position = follow_node.global_position
	var follower: AudioFollower = AudioFollower.new(new_player, follow_node)
	audio_followers.append(follower)
	new_player.finished.connect(destroy_player.bind(follower))
	new_player.play()
	return new_player
	
func play_spatial_sound_3d(
		sound: SoundEffect, 
		follow_node: Node3D
	) -> SpatialAudioPlayer3D:
	var new_player: SpatialAudioPlayer3D = SPATIAL_AUDIO_PLAYER_SCENE.instantiate() as SpatialAudioPlayer3D
	self.add_child(new_player)
	new_player.stream = sound.stream
	new_player.volume_db = sound.volume_db
	new_player.bus = sound.bus
	new_player.global_position = follow_node.global_position
	var follower: AudioFollower = AudioFollower.new(new_player, follow_node)
	audio_followers.append(follower)
	new_player.finished.connect(destroy_player.bind(follower))
	new_player.play()
	return new_player
	
func destroy_player(follower: AudioFollower) -> void:
	audio_followers.erase(follower)
	follower.audio_player.queue_free()
