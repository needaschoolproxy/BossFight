extends AnimatedSprite2D
@onready var character_body_2d: CharacterBody2D = $".."
@onready var animated_sprite_2d_2: AnimatedSprite2D = $"."


func _process(_delta: float) -> void:
	if character_body_2d.can_dash == true:
		animated_sprite_2d_2.play("on")
	else: animated_sprite_2d_2.play("off")
