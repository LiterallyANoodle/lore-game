class_name Enemy extends CharacterBody3D

@export var health: int = 3
@export var speed: float = 5.0

func decrement_health(amount: int = 1) -> void:
	print("Hit Zecora")
	self.health -= amount
	if health <= 0:
		self.death()

func death() -> void:
	print("Zecora died")
	self.queue_free()
