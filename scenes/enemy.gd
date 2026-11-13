class_name Enemy extends CharacterBody3D

@export var health: int = 3
@export var speed: float = 5.0

@onready var player_location_timer_seconds: float = 0.1
@onready var player_location_timer_remaining: int = 1
@onready var navigation_enabled: bool = true

@onready var navigation: NavigationAgent3D = $NavigationAgent3D
var player: CharacterBody3D

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")

func _physics_process(delta: float) -> void:
	navigation.target_position = player.global_position
	look_at(player.global_position)
		
	if not navigation.is_navigation_finished() and navigation_enabled:
		var next_point: Vector3 = navigation.get_next_path_position()
		var next_direction: Vector3 = global_position.direction_to(next_point)
		next_direction.y = 0
		var horizontal_velocity: Vector3 = next_direction * speed
		velocity.x = horizontal_velocity.x
		velocity.z = horizontal_velocity.z
		move_and_slide()
		

func decrement_health(amount: int = 1) -> void:
	print("Hit Zecora")
	self.health -= amount
	if health <= 0:
		self.death()

func death() -> void:
	print("Zecora died")
	self.queue_free()

func _on_enemy_melee_controller_enemy_begin_attack() -> void:
	navigation_enabled = false

func _on_enemy_melee_controller_enemy_finish_attack() -> void:
	navigation_enabled = true
