extends Area2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var area_2d: Area2D = $"."
@onready var lightning_sfx: AudioStreamPlayer2D = $LightningSfx


var DAMAGE := 15
var KNOCKBACK := Vector2(0, -300)

func _ready() -> void:
	$CollisionShape2D.disabled = true
	await get_tree().create_timer(0.6).timeout
	$CollisionShape2D.disabled = false
	$AnimatedSprite2D.play("default")
	$LightningSfx.play()

func _process(_delta: float) -> void:
	if not ray_cast_2d.is_colliding():
		position.y += 1  

func _on_body_entered(body: Node) -> void:
	if body.has_method("take_damage"):
		body.take_damage(DAMAGE, KNOCKBACK)




func _on_animated_sprite_2d_animation_finished() -> void:
	queue_free()
