extends CharacterBody2D
@onready var character = get_parent().get_parent().get_node("Node2D2/CharacterBody2D")
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack: RayCast2D = $Attack
@export var fireball = preload("res://scenes/fireball.tscn")
@onready var attack_timer: Timer = $"Attack Timer"
@onready var marker: Marker2D = $Marker2D
@onready var follow: RayCast2D = $Follow
var health := 150
var is_hurt := false
var knockback := Vector2.ZERO
const SPEED := 200
const HURT_DURATION := 0.15
enum State {IDLE, FOLLOW, ATTACK}
var state = State.IDLE
func _physics_process(delta: float) -> void:
	look_at(character.position)
	if health <= 0: return queue_free()
	if knockback.length() > 10:
		velocity = knockback
		knockback = knockback.move_toward(Vector2.ZERO, 800 * delta)
	else:
		match state:
			State.FOLLOW: velocity = (character.position - position).normalized() * SPEED
			_: velocity = Vector2.ZERO
	move_and_slide()
	if attack.get_collider() == character:
		state = State.ATTACK
	elif follow.get_collider() == character:
		state = State.FOLLOW
	else:
		state = State.IDLE
	sprite.play(["Idle","spawn","Attacking"][state])
	
func take_damage(dmg: int, kb: Vector2) -> void:
	health -= dmg
	knockback = kb
	is_hurt = true
	attack_timer.stop()              
	sprite.modulate = Color(1,0.5,0.5)
	await get_tree().create_timer(HURT_DURATION).timeout
	sprite.modulate = Color(1,1,1)
	is_hurt = false
	await get_tree().create_timer(1).timeout
	attack_timer.start()
func _on_attack_timer_timeout() -> void:
	if state == State.ATTACK and not is_hurt:
		var fb = fireball.instantiate()
		owner.add_child(fb)
		fb.global_transform = marker.global_transform
