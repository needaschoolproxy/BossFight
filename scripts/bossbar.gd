extends TextureProgressBar
@onready var argis: CharacterBody2D = $".."

func _process(_delta: float) -> void:
	if value >= argis.health:
		value -= 1
	if value <= argis.health:
		value += 1
