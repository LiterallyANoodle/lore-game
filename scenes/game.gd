extends Node

@export var score_goal: int = 100
@export var player_max_health: int = 10
@export var player_score: int = 0
@export var enemy_spawn_time_seconds: float = 5
@export var godmode: bool = false
@export var low_health_phrases: Array[String] = [ 
	"OH FUCK", 
	"SWEET CELESTIA", 
	"HITLER SAVE ME",
	"FUCKFUCKFUCKFUCK",
	"IT'S SO OVER",
	"YOU'RE FUCKED BUDDY",
	"PANIC IMMEDIATELY",
	"DON'T GO INTO THE LIGHT",
	"THOUGHTS AND PRAYERS",
	"CELESTIA WOULD BE DISAPPOINTED",
	"HAVE FUN DYING",
	"OH GOD OH FUCK",
	"TRY NOT GETTING HIT"
]

@onready var enemy_spawn_time_remaining: float = 0
@onready var player_health_remaining: int = player_max_health

@onready var death_screen: PackedScene = preload("res://scenes/death_screen.tscn")

func _ready() -> void:
	SignalBus.ENEMY_DEATH.connect(_on_enemy_death)
	HUD.update_player_health_display(player_health_remaining)
	HUD.update_player_score_display(0)
	
func _process(delta: float) -> void:
	enemy_spawn_time_remaining -= delta
	if enemy_spawn_time_remaining <= 0:
		enemy_spawn_time_remaining = enemy_spawn_time_seconds
		SignalBus.SPAWN_ENEMY.emit()
	
func _on_enemy_death() -> void:
	increment_player_score()
	
func increment_player_score(amount: int = 1) -> void:
	player_score += 1 
	HUD.update_player_score_display(player_score)
	
func decrement_player_health(amount: int = 1) -> void:
	SignalBus.PLAYER_DAMAGED.emit()
	if !godmode:
		player_health_remaining -= amount
		if player_health_remaining > 1:
			HUD.update_player_health_display(player_health_remaining)
		else:
			HUD.update_player_health_display(low_health_phrases.pick_random())
			
		if player_health_remaining <= 0: 
			SignalBus.PLAYER_DEATH.emit()
			HUD.update_player_health_display("IT'S OVER")
			var new_death_screen: Control = death_screen.instantiate()
			get_tree().current_scene.add_child(new_death_screen)

func enemy_apply_attack() -> void:
	print("Apply attack")
	decrement_player_health()
