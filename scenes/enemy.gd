extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var health := 3000
var knockback_velocity := Vector2.ZERO
const GRAVITY := 2000.0
const HURT_DURATION := 0.25
var is_hurt := false

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		velocity.y = 0

	if knockback_velocity.length() > 10.0:
		velocity = knockback_velocity
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 1000.0 * delta)
	else:
		knockback_velocity = Vector2.ZERO

	move_and_slide()

	if health <= 0:
		queue_free()
		return

	if not is_hurt and sprite.animation != "Idle":
		sprite.play("Idle")

func take_damage(damage: int, knockback: Vector2) -> void:
	health -= damage
	knockback_velocity = knockback

	if health <= 0:
		queue_free()
		return

	if sprite.sprite_frames and sprite.sprite_frames.has_animation("Hurt"):
		is_hurt = true
		sprite.play("Hurt")
		await get_tree().create_timer(HURT_DURATION).timeout
		is_hurt = false
