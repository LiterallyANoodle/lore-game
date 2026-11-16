class_name AmmoIndicator extends Node3D

@export var sprite_texture: Texture2D

@onready var display_count: int = 0
@onready var sprite_array: Array[Sprite2D] = []

func update_ammo_display(amount: int) -> void:
	for s: Sprite2D in sprite_array:
		s.queue_free()
	
	for i: int in amount:
		var new_sprite: Sprite2D = Sprite2D.new()
		sprite_array.append(new_sprite)
		new_sprite.texture = sprite_texture
		new_sprite.position.y = i * new_sprite.texture.get_height()
		self.add_child(new_sprite)
