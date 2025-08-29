extends CharacterBody2D

@onready var character = get_parent().get_parent().get_node("Node2D2/CharacterBody2D")
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hit_area: Area2D = $HitArea

const SPEED = 200
var health := 500
var knockback_velocity := Vector2.ZERO
const HURT_DURATION := 0.25
var is_hurt := false
var DAMAGE := 20
var KNOCKBACK := 300.0

var hit_bodies := []

func _ready():
	hit_area.monitoring = true
	if not hit_area.is_connected("body_entered", Callable(self, "_on_hit_area_body_entered")):
		hit_area.connect("body_entered", Callable(self, "_on_hit_area_body_entered"))
	if not hit_area.is_connected("body_exited", Callable(self, "_on_hit_area_body_exited")):
		hit_area.connect("body_exited", Callable(self, "_on_hit_area_body_exited"))

func _physics_process(delta: float) -> void:
	if not character:
		return

	var direction = (character.global_position - global_position).normalized()
	velocity = direction * SPEED

	if knockback_velocity.length() > 10.0:
		velocity = knockback_velocity
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 1000.0 * delta)
	else:
		knockback_velocity = Vector2.ZERO

	move_and_slide()

	if direction.x != 0:
		sprite.flip_h = direction.x < 0

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
	else:
		is_hurt = true
		var original_modulate := sprite.modulate
		sprite.modulate = Color(1, 0.5, 0.5)
		await get_tree().create_timer(HURT_DURATION).timeout
		sprite.modulate = original_modulate
		is_hurt = false

func _on_hit_area_body_entered(body):
	if body.has_method("take_damage") and not body in hit_bodies:
		hit_bodies.append(body)
		var knock_dir = (body.global_position - global_position).normalized()
		body.take_damage(DAMAGE, knock_dir * KNOCKBACK)

func _on_hit_area_body_exited(body):
	if body in hit_bodies:
		hit_bodies.erase(body)
