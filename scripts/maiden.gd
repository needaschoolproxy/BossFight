extends CharacterBody2D
@onready var character_body_2d: CharacterBody2D = $"../CharacterBody2D"
@onready var icon: Sprite2D = $Icon
@onready var marker_2d: Marker2D = $Marker2D
@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var follow_area: Area2D = $FollowArea
@onready var stomptimer: Timer = $Stomptimer

const HURT_DURATION = 0.1
const SPEED = 2.5
const STOMP_SPEED = 3.5
var health = 900
var knockback := Vector2.ZERO
var is_hurt = false
enum state{inactive,idle,stomp,shoot,swoopready,swoopattack}
var current_state = state.inactive

const SPINE = preload("uid://bggra0uuaiiwo")

func _process(delta: float) -> void:
	if knockback.length() > 10:
		velocity = knockback
		knockback = knockback.move_toward(Vector2.ZERO, 100)
	 
	
	match current_state:
		state.idle:
			position.y = lerp(position.y,character_body_2d.position.y - 350,SPEED * delta)
			position.x = lerp(position.x,character_body_2d.position.x,SPEED * delta)
			look_at($"../CharacterBody2D".position)
		state.stomp:
			position.y = lerp(position.y,character_body_2d.position.y,STOMP_SPEED * delta)
			if rotation_degrees > 0:
				rotation_degrees -= 4
		state.shoot:
			look_at($"../CharacterBody2D".position)
		state.swoopready:
			position.y = lerp(position.y,character_body_2d.position.y - 150,SPEED * delta)
			position.x = lerp(position.x,character_body_2d.position.x + 500,STOMP_SPEED * delta)
		state.swoopattack:
			position.x = lerp(position.x,character_body_2d.position.x - 500,STOMP_SPEED * delta)
			look_at($"../CharacterBody2D".position)
			
			
	if follow_area.overlaps_body($"../CharacterBody2D"):
		$CanvasLayer.visible = true
	else:$CanvasLayer.visible = false
	
	if health <= 0: return queue_free()
	move_and_slide()


func take_damage(dmg: int, kb: Vector2) -> void:
	health -= dmg
	knockback = kb
	is_hurt = true            
	$Icon.modulate = Color(1.25,0.5,0.5,)
	await get_tree().create_timer(HURT_DURATION).timeout
	$Icon.modulate = Color(1,1,1)
	is_hurt = false

func _on_shoot_timer_timeout() -> void:
	if current_state == state.idle:
		current_state = state.shoot
		for i in randi_range(8,20):
			var new_spine = SPINE.instantiate()
			owner.add_child(new_spine)
			new_spine.global_transform = $Marker2D.global_transform
			new_spine.rotation = rotation + randf_range(-0.5,0.5)
			await get_tree().create_timer(0.02).timeout
		current_state = state.idle

func _on_stomptimer_timeout() -> void:
	if current_state == state.idle:
		for i in randi_range(1,3):
			current_state = state.stomp
			await get_tree().create_timer(1).timeout
			current_state = state.idle
			await get_tree().create_timer(0.75).timeout


func _on_follow_area_body_entered(_body: Node2D) -> void:
	current_state = state.idle


func _on_area_2d_body_entered(_body: Node2D) -> void:
	if current_state == state.stomp or state.stomp:
		$"../CharacterBody2D".health -= 5


func _on_swooptimer_timeout() -> void:
	if current_state == state.idle:
		current_state = state.swoopready
		await get_tree().create_timer(1.5).timeout
		current_state = state.swoopattack
