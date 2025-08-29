extends CharacterBody2D

@onready var character = get_parent().get_parent().get_node("Node2D2/CharacterBody2D")
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var follow_area: Area2D = $FollowArea
@onready var ray_cast_2d: RayCast2D = $RayCast2D
@export var fireball = preload("res://scenes/fireball.tscn")
@onready var attack_timer: Timer = $"Attack Timer"
@onready var marker_2d: Marker2D = $Marker2D

var is_hurt = false
const HURT_DURATION = 0.15
var knockback_velocity := Vector2.ZERO
const SPEED = 200
var health := 100
var player_position
var target_position
enum state {idle,follow,attack}
var current_state = state.idle

func _physics_process(_delta: float) -> void:
	look_at(character.position)
	player_position = character.position
	target_position = (player_position - position).normalized()
	
	if health <= 0:
		queue_free()
		return
	
	if position.x > character.position.x:
		$AnimatedSprite2D.flip_v

func _process(_delta: float) -> void:
	match current_state:
		state.idle:
			$AnimatedSprite2D.play("Idle")
		state.follow:
			$AnimatedSprite2D.play("spawn")
			if position.distance_to(player_position) > 3:
				velocity = target_position * SPEED
				move_and_slide()
		state.attack:
			$AnimatedSprite2D.play("Attacking")
			
	
	
	if ray_cast_2d.get_collider() == character:
		current_state = state.attack
	else: if follow_area.overlaps_body(character): 
		current_state = state.follow
	else: if follow_area.body_exited: 
		current_state = state.idle

	
func _on_follow_area_body_entered(_body: Node2D) -> void:
	current_state = state.follow
	
func _on_follow_area_body_exited(_body: Node2D) -> void:
	current_state = state.idle

func take_damage(damage: int, knockback: Vector2) -> void:
	health -= damage
	knockback_velocity = knockback
	
	var frames := sprite.sprite_frames
	if frames and frames.has_animation("Hurt"):
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

func _on_attack_timer_timeout() -> void:
	if current_state == state.attack:
		var newfireball = fireball.instantiate()
		owner.add_child(newfireball)
		newfireball.transform = $Marker2D.global_transform
		
