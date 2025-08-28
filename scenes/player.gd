extends CharacterBody2D
@onready var dash_time: Timer = $DashTime
@onready var dash_cooldown_timer: Timer = $DashCooldownTimer
var SPEED = 350.0
const JUMP_VELOCITY = -500.0
var doublejumped = false
const DASH_SPEED = 1200
var dashing = false
var can_dash = true

func _physics_process(delta: float) -> void: 
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	else: if Input.is_action_just_pressed("jump") and doublejumped == false:
		velocity.y = JUMP_VELOCITY
		doublejumped = true
	if is_on_floor():
		doublejumped = false
		
	var direction := Input.get_axis("left", "right")
	if direction:
		if dashing == true:
			velocity.x = direction * DASH_SPEED
		else:
			velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	if Input.is_action_just_pressed("dash") and can_dash == true:
		dashing = true
		can_dash = false
		$DashTime.start()
		$DashCooldownTimer.start()
	move_and_slide()
	
func _on_dash_time_timeout() -> void:
	dashing = false
	
func _on_dash_cooldown_timer_timeout() -> void:
	can_dash = true
