class_name PlayerMeleeController extends Node3D

enum Weapon { MELEE }

signal PLAYER_START_MELEE
signal PLAYER_APPLY_MELEE
signal PLAYER_FINISH_MELEE

@export var knockback_force: float = 15.0
@export var knockback_bias: float = 0.60
@export var knockback_lift: float = 0.5

@onready var queued_right_click: bool = false
@onready var queued_apply_attack: bool = false

@onready var area: Area3D = $Area3D
@onready var sprite: AnimatedSprite3D = $Area3D/CollisionShape3D/AnimatedSprite3D

func _ready() -> void:
	sprite.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("Right Mouse"):
		queued_right_click = true
		
func _process(delta: float) -> void:
	if queued_right_click:
		queued_right_click = false
		PLAYER_START_MELEE.emit()
		sprite.stop()
		sprite.visible = true
		sprite.play("whack")

func _physics_process(delta: float) -> void:
	if queued_apply_attack:
		queued_apply_attack = false
		var targets: Array[Node3D] = area.get_overlapping_bodies()
		for t: Node3D in targets:
			if t.get_groups().any(func(group: StringName) -> bool: return group == "Enemy"):
				print("Melee hit enemy")
				t.decrement_health()
				# apply some knockback velocity
				var away: Vector3 = global_position.direction_to(t.global_position)
				away.y = 0 # get horizontal direction only 
				away = away.normalized() 
				
				var forward: Vector3 = -get_viewport().get_camera_3d().global_basis.z
				forward.y = 0.0
				forward = forward.normalized()
				
				var dir: Vector3 = away.lerp(forward, knockback_bias).normalized()
				
				# hit them upwards
				dir.y = knockback_lift
				dir = dir.normalized()
				
				t.receive_knockback(dir * knockback_force)

func _on_animated_sprite_3d_animation_finished() -> void:
	sprite.visible = false
	PLAYER_FINISH_MELEE.emit()

func _on_animated_sprite_3d_frame_changed() -> void:
	if sprite.frame == 1:
		PLAYER_APPLY_MELEE.emit()
		queued_apply_attack = true
