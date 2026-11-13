class_name EnemyMeleeController extends Node3D

signal ENEMY_BEGIN_ATTACK
signal ENEMY_APPLY_ATTACK(body: CharacterBody3D)
signal ENEMY_FINISH_ATTACK

@export var auto_attack_enabled: bool = true
@export var auto_attack_seconds: float = 5

@onready var auto_attack_time_remaining: int = 0
@onready var player_in_range: CharacterBody3D = null

@onready var area: Area3D = $Area3D
@onready var sprite: AnimatedSprite3D = $Area3D/CollisionShape3D/AnimatedSprite3D

func _ready() -> void:
	sprite.visible = false
	
func _process(delta: float) -> void:
	if auto_attack_enabled:
		if auto_attack_time_remaining <= 0 and !sprite.is_playing():
			if player_in_range != null:
				auto_attack_time_remaining = auto_attack_seconds
				begin_attack()

	auto_attack_time_remaining -= delta

func begin_attack() -> void:
	ENEMY_BEGIN_ATTACK.emit() # for halting movement while attacking
	sprite.stop()
	sprite.visible = true
	sprite.play("bite")

func apply_attack() -> void:
	# check frames until the attack frame
	if sprite.frame == 3:
		ENEMY_APPLY_ATTACK.emit(player_in_range)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body == get_tree().get_first_node_in_group("Player"):
		player_in_range = body
			
func _on_area_3d_body_exited(body: Node3D) -> void:
	if body == get_tree().get_first_node_in_group("Player"):
		player_in_range = null

func _on_animated_sprite_3d_animation_finished() -> void:
	ENEMY_FINISH_ATTACK.emit()
	sprite.visible = false
	auto_attack_time_remaining = auto_attack_seconds
