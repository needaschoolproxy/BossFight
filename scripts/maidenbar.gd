extends TextureProgressBar
@onready var maiden: CharacterBody2D = $"../.."
@onready var texture_progress_bar: TextureProgressBar = $"."




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if texture_progress_bar.value >= maiden.health:
		texture_progress_bar.value -= 1
	if texture_progress_bar.value <= maiden.health:
		texture_progress_bar.value += 1
