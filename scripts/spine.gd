extends RigidBody2D
@onready var area_2d: Area2D = $Area2D



const SPEED = 500
const DAMAGE = 5

func _ready() -> void:
	pass # Replace with function body.


func _process(delta: float) -> void:
	position += transform.x * SPEED * delta


func _on_timer_timeout() -> void:
	queue_free()
