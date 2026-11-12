class_name AimController extends Node3D

enum Weapon { GUN, MELEE }

@export var range: float = 500
@export var enable_hitmarkers: bool = false

@onready var queued_left_click: bool = false
@onready var queued_right_click: bool = false

@onready var hitmarker: PackedScene = preload("res://scenes/hitmarker.tscn")

@onready var raycast: RayCast3D = $RayCast3D

func _onready() -> void:
	raycast.target_position = Vector3(0, 0, -range)

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("Left Mouse"):
		queued_left_click = true
	if Input.is_action_just_pressed("Right Mouse"):
		queued_right_click = true

func _physics_process(delta: float) -> void:
	
	if queued_left_click:
		
		queued_left_click = false
		SignalBus.WEAPON_FIRED.emit(Weapon.GUN)
		raycast.force_raycast_update()

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

	if queued_right_click:
		queued_right_click = false
		pass
