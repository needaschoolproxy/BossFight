extends ColorRect
@onready var character_body_2d: CharacterBody2D = $".."
@onready var color_rect: ColorRect = $"."



func _process(delta: float) -> void:
	if character_body_2d.can_dash == true:
		self_modulate = Color(0,1,2)
	else: self_modulate = Color(2,2,3)
