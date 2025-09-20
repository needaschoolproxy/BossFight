extends CharacterBody2D
@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var marker_2d: Marker2D = $Marker2D
@onready var bullettimer: Timer = $bullettimer
@onready var character = get_parent().get_node("Node2D2/CharacterBody2D")

var fireball = preload("res://scenes/fireball.tscn")

var knockback := Vector2.ZERO
var health = 50
var is_hurt = false
const HURT_DURATION = 0.2
enum state{idle,shoot,glide}
var current_state = state.idle
var targetx;
var targety;
var speed = 12


func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	if knockback.length() > 10:
		velocity = knockback
		knockback = knockback.move_toward(Vector2.ZERO, 500)
	match current_state:
		state.idle: animated_sprite_2d.play("idle")
		state.shoot:animated_sprite_2d.play("shoot")
			
	if $CharacterBody2D.position.x < position.x:
		$AnimatedSprite2D.flip_v = true
	else: $AnimatedSprite2D.flip_v = false
	
	if health <= 0: return queue_free()
	look_at($CharacterBody2D.position)
	move_and_slide()


func _on_bullettimer_timeout() -> void:
	if ray_cast_2d.is_colliding():
		current_state = state.shoot
		await get_tree().create_timer(0.5).timeout
		shoot()
		current_state = state.idle
		glide()
		

func _on_animated_sprite_2d_animation_finished() -> void:
	pass
	
func shoot():
	var new_fireball = fireball.instantiate()
	owner.add_child(new_fireball)
	new_fireball.global_transform = marker_2d.global_transform
	
	
func take_damage(dmg: int, kb: Vector2) -> void:
	health -= dmg
	knockback = kb
	is_hurt = true            
	$AnimatedSprite2D.modulate = Color(1.25,0.5,0.5,)
	await get_tree().create_timer(HURT_DURATION).timeout
	$AnimatedSprite2D.modulate = Color(1,1,1)
	is_hurt = false
	await get_tree().create_timer(1).timeout


func glide():
	targetx = randf_range(-25,25)
	targety = randf_range(-15,15)
	velocity.x = targetx * speed
	velocity.y = targety * speed
	await get_tree().create_timer(randf_range(0.3,0.5)).timeout
	velocity.x = 0
	velocity.y = 0
	move_and_slide()
