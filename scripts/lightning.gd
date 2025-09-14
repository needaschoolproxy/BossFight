extends Area2D
@onready var ray_cast_2d: RayCast2D = $RayCast2D




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if not $RayCast2D.is_colliding():
		position.y += 1


func _on_animated_sprite_2d_animation_finished() -> void:
	queue_free()
