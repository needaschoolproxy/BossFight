extends CanvasLayer

@onready var argis: CharacterBody2D = $".."
@onready var texture_progress_bar: TextureProgressBar = $TextureProgressBar

func _process(_delta: float) -> void:
	if texture_progress_bar.value >= argis.health:
		texture_progress_bar.value -= 1
	if texture_progress_bar.value <= argis.health:
		texture_progress_bar.value += 1
