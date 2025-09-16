extends CharacterBody2D
@onready var character_body_2d: CharacterBody2D = $"../CharacterBody2D"
@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var marker_2d: Marker2D = $Marker2D

var fireball = preload("res://scenes/fireball.tscn")

var health = 50
var is_hurt = false
const HURT_DURATION = 0.2
enum state{idle,shoot,glide}
var current_state = state.idle

func _ready() -> void:
	set_process(true)

func _process(_delta: float) -> void:
	match current_state:
		state.idle: animated_sprite_2d.play("idle")
		state.shoot:animated_sprite_2d.play("shoot")
		state.glide:
			animated_sprite_2d.play("idle")
			

	if character_body_2d.position.x < position.x:
		$AnimatedSprite2D.flip_v = true
	else: $AnimatedSprite2D.flip_v = false
	
	if health <= 0: return queue_free()
	look_at(character_body_2d.position)


func _on_bullettimer_timeout() -> void:
	if ray_cast_2d.is_colliding():
				current_state = state.shoot
				await get_tree().create_timer(0.5).timeout
				shoot()


func _on_animated_sprite_2d_animation_finished() -> void:
	pass
	
func shoot():
	var new_fireball = fireball.instantiate()
	owner.add_child(new_fireball)
	new_fireball.global_transform = marker_2d.global_transform
	
