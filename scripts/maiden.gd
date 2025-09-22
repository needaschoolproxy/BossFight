extends CharacterBody2D
@onready var character_body_2d: CharacterBody2D = $"../CharacterBody2D"
@onready var icon: Sprite2D = $Icon

const HURT_DURATION = 0.1
const SPEED = 2.5
const STOMP_SPEED = 4
var health = 900
var knockback := Vector2.ZERO
var is_hurt = false
enum state{idle,stomp}
var current_state = state.idle


func _process(delta: float) -> void:
	if knockback.length() > 10:
		velocity = knockback
		knockback = knockback.move_toward(Vector2.ZERO, 500)
	
	match current_state:
		state.idle:
			position.y = lerp(position.y,character_body_2d.position.y - 360,SPEED * delta)
			position.x = lerp(position.x,character_body_2d.position.x,SPEED * delta)
			look_at($"../CharacterBody2D".position)
		state.stomp:
			position.y = lerp(position.y,character_body_2d.position.y,STOMP_SPEED * delta)
			
			
	if health <= 0: return queue_free()
	move_and_slide()
	

func _on_timer_timeout() -> void:
	for i in 3:
		current_state = state.stomp
		await get_tree().create_timer(0.85).timeout
		current_state = state.idle
		await get_tree().create_timer(0.75).timeout


func take_damage(dmg: int, kb: Vector2) -> void:
	health -= dmg
	knockback = kb
	is_hurt = true            
	$Icon.modulate = Color(1.25,0.5,0.5,)
	await get_tree().create_timer(HURT_DURATION).timeout
	$Icon.modulate = Color(1,1,1)
	is_hurt = false


func _on_area_2d_body_entered() -> void:
	$"../CharacterBody2D".health -= 6
