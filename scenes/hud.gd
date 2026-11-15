extends Control

@onready var health: Label = $Health
@onready var score: Label = $Score

func update_player_health_display(value: Variant) -> void:
	var full_string: String = "Aryanne Spirit\n"
	full_string +=  str(value)
	health.text = full_string
	
func update_player_score_display(value: Variant) -> void:
	var full_string: String = "Creatures Destroyed\n"
	full_string +=  str(value)
	score.text = full_string
