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
@onready var audio_streams: Dictionary = {
	"cylinder_slam": preload("res://resources/cylinder_slam.ogg"),
	"rod_push": preload("res://resources/rod_push.ogg"),
	"trigger_empty": preload("res://resources/trigger_empty.ogg"),
	"trigger_shoot": preload("res://resources/lecker_shoot.ogg")
}

@onready var raycast: RayCast3D = $RayCast3D
@onready var gun_sprite: AnimatedSprite3D = $Gun
@onready var ammo_indicator: AmmoIndicator = $AmmoIndicator
@onready var spatial_audio_player: SpatialAudioPlayer3D = $SpatialAudioPlayer3D

func _ready() -> void:
	raycast.target_position = Vector3(0, 0, -range)
	ammo_indicator.update_ammo_display(magazine_current_amount)
	SignalBus.WEAPON_FIRED.connect(play_weapon_animation)

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
		ammo_indicator.update_ammo_display(magazine_current_amount)
		play_sound("trigger_shoot")
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
	# gun is empty
	elif queued_left_click and magazine_current_amount <= 0:
		queued_left_click = false
		play_sound("trigger_empty")
				
func start_reload() -> void:
	print("Start reload with amount: " + str(magazine_current_amount))
	if magazine_current_amount < magazine_max_size:
		reload_round()
	else:
		reload_round_last()
	
func reload_round() -> void:
	gun_sprite.stop()
	gun_sprite.play("reload")
	
func apply_reload_round() -> void:
	if gun_sprite.animation == "reload" and gun_sprite.frame == 1:
		SignalBus.APPLY_RELOAD_ROUND.emit()
		magazine_current_amount += 1
		ammo_indicator.update_ammo_display(magazine_current_amount)
		play_sound("rod_push")

func _on_gun_animation_finished() -> void:
	if gun_sprite.animation == "reload":
		print("Frame reload round done")
		# start reloading next round
		start_reload()

func reload_round_last() -> void:
	reloading = false
	SignalBus.FINISH_RELOAD_LAST.emit()
	gun_sprite.stop()
	gun_sprite.play("idle")
	play_sound("cylinder_slam")
	
func play_weapon_animation(weapon: AimController.Weapon) -> void:
	if AimController.Weapon.GUN == weapon:
		gun_sprite.stop()
		gun_sprite.play("fire")
		
func play_sound(name: String) -> void:
	spatial_audio_player.stream = audio_streams[name]
	spatial_audio_player.play()
