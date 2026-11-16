class_name AmmoIndicator extends Node3D

@export var sprite_texture: Texture2D

@onready var display_count: int = 0
@onready var sprite_array: Array[Sprite3D] = []

func update_ammo_display(amount: int) -> void:
	print("Updating ammo display to " + str(amount))
	for s: Sprite3D in sprite_array:
		s.queue_free()
	sprite_array.clear()
	
	for i: int in amount:
		var new_sprite: Sprite3D = Sprite3D.new()
		sprite_array.append(new_sprite)
		new_sprite.texture = sprite_texture
		new_sprite.shaded = false
		new_sprite.no_depth_test = true
		new_sprite.render_priority = 1
		new_sprite.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR
		new_sprite.position.y = i * new_sprite.texture.get_height() * new_sprite.pixel_size
		self.add_child(new_sprite)
