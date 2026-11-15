class_name Gibs extends GPUParticles3D

func _ready() -> void:
	self.emitting = true

func _on_finished() -> void:
	self.queue_free()
