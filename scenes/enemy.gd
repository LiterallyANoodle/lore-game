class_name Enemy extends CharacterBody3D

@export var health: int = 3
# @export var speed: float = 10.0
@export var acceleration: float = 0.15
@export var velocity_damping_factor: float = 0.01
@export var has_gravity: bool = true

@onready var player_location_timer_seconds: float = 0.1
@onready var player_location_timer_remaining: int = 1
@onready var navigation_enabled: bool = true
@onready var queued_knockback: Vector3 = Vector3.ZERO

var player: CharacterBody3D

@onready var navigation: NavigationAgent3D = $NavigationAgent3D
@onready var spatial_audio_player: SpatialAudioPlayer3D = $SpatialAudioPlayer3D

@onready var gibs: PackedScene = preload("res://scenes/gibs.tscn")
@onready var audio_streams: Dictionary = {
	"enemy_hurt": preload("res://resources/enemy_hurt.ogg")
}

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")

func _physics_process(delta: float) -> void:
	navigation.target_position = player.global_position
	look_at(player.global_position)
	
	# Apply gravity to velocity
	if has_gravity:
		if not is_on_floor():
			velocity += get_gravity() * delta
		
	# apply navigation
	if not navigation.is_navigation_finished() and navigation_enabled:
		var next_point: Vector3 = navigation.get_next_path_position()
		var next_direction: Vector3 = global_position.direction_to(next_point)
		next_direction.y = 0
		var horizontal_velocity: Vector3 = velocity
		horizontal_velocity.y = 0
		horizontal_velocity += next_direction * acceleration
		var damped_velocity: Vector3 = horizontal_velocity - (horizontal_velocity * velocity_damping_factor)
		velocity.x = damped_velocity.x
		velocity.z = damped_velocity.z
	
	velocity += queued_knockback
	queued_knockback = Vector3.ZERO
	move_and_slide()

func decrement_health(amount: int = 1) -> void:
	print("Hit Zecora")
	self.health -= amount
	spawn_gibs(5)
	if health <= 0:
		self.death()
	else:
		play_sound("enemy_hurt")

func death() -> void:
	print("Zecora died")
	SignalBus.ENEMY_DEATH.emit()
	spawn_gibs(50)
	self.queue_free()
	
func receive_knockback(amount: Vector3) -> void:
	queued_knockback = amount

func _on_enemy_melee_controller_enemy_begin_attack() -> void:
	navigation_enabled = false

func _on_enemy_melee_controller_enemy_finish_attack() -> void:
	navigation_enabled = true
	
func spawn_gibs(amount: int) -> void:
	var new_gibs: Gibs = gibs.instantiate()
	new_gibs.amount = amount
	new_gibs.global_position = self.global_position + Vector3(0, 0.5, 0)
	get_tree().current_scene.add_child(new_gibs)

func play_sound(name: String) -> void:
	spatial_audio_player.stream = audio_streams[name]
	spatial_audio_player.play()
