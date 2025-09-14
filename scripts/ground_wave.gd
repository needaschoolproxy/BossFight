extends RigidBody2D

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var collision_polygon_2d: CollisionPolygon2D = $Area2D/CollisionPolygon2D
@onready var groundwavesprite: Sprite2D = $Groundwavesprite


const SPEED: int = 500
var flip = false
const DAMAGE: int = 9
const KNOCKBACK: float = 600.0


func _process(delta: float) -> void:
	var dir := -1 if flip else 1
	position += transform.x * SPEED * dir * delta
	if flip:
		$Groundwavesprite.flip_h = true
		collision_shape_2d.scale.x = -1
		collision_polygon_2d.scale.x = -1
	

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		var knock_dir: int = -1 if flip else 1
		body.take_damage(DAMAGE, Vector2(knock_dir * KNOCKBACK, -200))
	queue_free()


	
