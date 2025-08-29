extends TextureProgressBar
@onready var character_body_2d: CharacterBody2D = $".."


func _process(delta: float) -> void:
	value = character_body_2d.displayed_health
	
	if character_body_2d.displayed_health != character_body_2d.health:
		character_body_2d.displayed_health -= 0.1
