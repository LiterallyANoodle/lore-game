extends Node

@export var player_max_health: int = 10
@export var player_score: int = 0
@export var enemy_spawn_time_seconds: float = 5

@onready var enemy_spawn_time_remaining: float = 0

func _ready() -> void:
	SignalBus.ENEMY_DEATH.connect(_on_enemy_death)
	
func _process(delta: float) -> void:
	enemy_spawn_time_remaining -= delta
	if enemy_spawn_time_remaining <= 0:
		enemy_spawn_time_remaining = enemy_spawn_time_seconds
		SignalBus.SPAWN_ENEMY.emit()
	
func _on_enemy_death() -> void:
	increment_player_score()
	
func increment_player_score(amount: int = 1) -> void:
	player_score += 1 
