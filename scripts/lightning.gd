extends Area2D

@onready var ray_cast_2d: RayCast2D = $RayCast2D
var DAMAGE := 15
var KNOCKBACK := Vector2(0, -300)

func _process(_delta: float) -> void:
	if not ray_cast_2d.is_colliding():
		position.y += 1  

func _on_animated_sprite_2d_animation_finished() -> void:
	queue_free()

func _on_body_entered(body: Node) -> void:
	if body.has_method("take_damage"):
		body.take_damage(DAMAGE, KNOCKBACK)
