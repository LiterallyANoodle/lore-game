class_name AimController extends Node3D

enum Weapon { GUN }

@export var range: float = 500
@export var magazine_max_size: int = 7
@export var enable_hitmarkers: bool = false

@onready var queued_left_click: bool = false
@onready var queued_reload: bool = false
@onready var magazine_current_amount: int = magazine_max_size
@onready var reloading: bool = false

@onready var hitmarker: PackedScene = preload("res://scenes/hitmarker.tscn")

@onready var raycast: RayCast3D = $RayCast3D

func _ready() -> void:
	raycast.target_position = Vector3(0, 0, -range)
	
	SignalBus.APPLY_RELOAD_ROUND.connect(apply_reload)
	SignalBus.FINISH_RELOAD_ROUND.connect(finish_reload_round)

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("Left Mouse"):
		queued_left_click = true
	if Input.is_action_just_pressed("Reload"):
		queued_reload = true
		
func _process(delta: float) -> void:
	if queued_reload:
		queued_reload = false
		queued_left_click = false
		reloading = true
		start_reload()

func _physics_process(delta: float) -> void:
	
	if queued_left_click and magazine_current_amount > 0:
		# Reloading can be interrupted by shooting.
		# _process and _physics_process run mutually exclusively by default,
		# so this is safe as long as threads aren't added.
		reloading = false
		queued_reload = false
		queued_left_click = false
		
		SignalBus.WEAPON_FIRED.emit(Weapon.GUN)
		raycast.force_raycast_update()
		magazine_current_amount -= 1
		print("Current mag: " + str(magazine_current_amount))

		if raycast.is_colliding():
			var collider: Node = raycast.get_collider()
			var collision_point: Vector3 = raycast.get_collision_point()
			print("Collider hit: ", collider.name, " ID: ", collider.name)
			print("Point hit: ", collision_point)
			
			SignalBus.GUN_HIT.emit(collider)
			if collider is Enemy:
				collider.decrement_health()

			if enable_hitmarkers:
				var hitmarker_instance: MeshInstance3D = hitmarker.instantiate()
				get_tree().current_scene.add_child(hitmarker_instance)
				hitmarker_instance.top_level = true
				hitmarker_instance.global_position = collision_point
				
func start_reload() -> void:
	print("Start reload with amount: " + str(magazine_current_amount))
	if magazine_current_amount < magazine_max_size:
		SignalBus.START_RELOAD.emit()
	else:
		reloading = false
		SignalBus.FINISH_RELOAD_LAST.emit()
	
func apply_reload() -> void:
	print("Apply reload round")
	magazine_current_amount += 1

func finish_reload_round() -> void:
	start_reload()
