class_name EnemySpawner extends Node3D

@onready var enemy_scene: PackedScene = preload("res://scenes/enemy.tscn")

func _ready() -> void:
	SignalBus.SPAWN_ENEMY.connect(_on_spawn_enemy)

func _on_spawn_enemy(amount: int = 1) -> void:
	var new_enemy: Enemy = enemy_scene.instantiate()
	new_enemy.global_position = self.global_position
	get_tree().current_scene.add_child(new_enemy)
