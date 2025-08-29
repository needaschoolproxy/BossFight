extends RigidBody2D

const SPEED = 800
@onready var character_body_2d: CharacterBody2D = $"../CharacterBody2D"



func _process(delta: float) -> void:
	position += transform.x * SPEED * delta
	
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		character_body_2d.health -= 10
	queue_free()
	
