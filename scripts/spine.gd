extends RigidBody2D


const SPEED = 500
const DAMAGE = 5

func _ready() -> void:
	pass # Replace with function body.


func _process(delta: float) -> void:
	position += transform.x * SPEED * delta
	

func _on_area_2d_body_entered(body: Node2D) -> void:
	pass
