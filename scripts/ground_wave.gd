extends RigidBody2D

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var collision_polygon_2d: CollisionPolygon2D = $Area2D/CollisionPolygon2D
@onready var groundwave: Sprite2D = $Groundwave

const SPEED = 500
var flip = false

func _ready() -> void:
	if flip == true:
		flipped()

func _process(delta: float) -> void:
	if flip == true:
		position += transform.x * -SPEED * delta
	else: position += transform.x * SPEED * delta


	
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		pass
	queue_free()

func flipped():
	collision_shape_2d.position.x *= -1
	collision_polygon_2d.position.x *= -1
	groundwave.flip_h
