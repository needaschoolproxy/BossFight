extends CharacterBody2D

@onready var dash_time: Timer = $DashTime
@onready var dash_cooldown_timer: Timer = $DashCooldownTimer
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area: Area2D = $AttackArea

var SPEED = 450.0
const JUMP_VELOCITY = -900.0
const GRAVITY = 2000.0
const FAST_FALL_MULTIPLIER = 2.0
const JUMP_CUT_MULTIPLIER = 0.5
var doublejumped = false
const DASH_SPEED = 1200
var dashing = false
var can_dash = true
var attacking = false
var ATTACK_DAMAGE = 20
var ATTACK_KNOCKBACK = 400.0
var can_attack = true
const ATTACK_COOLDOWN = 0.5

var jumping = false

enum state {idle,run,jump,attack,dash}
var current_state = state.idle

func _process(delta: float) -> void:
	match current_state:
		state.idle:
			sprite.play("Idle")
		state.run:
			sprite.play("MoveLeftRight")
		state.jump:
			sprite.play("Jump")
		state.attack:
			sprite.play("Attack")
		state.dash:
			sprite.play("Dash")
			set_collision_mask_value(2,false)

	if not is_on_floor():
		if velocity.y > 0:
			velocity.y += GRAVITY * FAST_FALL_MULTIPLIER * delta
		else:
			velocity.y += GRAVITY * delta
		current_state = state.jump
	else: 
		doublejumped = false
		current_state = state.idle
		velocity.y = 0
		if jumping:
			jumping = false

	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
		elif not doublejumped:
			velocity.y = JUMP_VELOCITY
			doublejumped = true

	if not Input.is_action_pressed("jump") and velocity.y < 0:
		velocity.y *= JUMP_CUT_MULTIPLIER

	var direction := Input.get_axis("left", "right")
	if direction != 0:
		current_state = state.run
		if dashing:
			velocity.x = direction * DASH_SPEED
		else:
			velocity.x = direction * SPEED
		sprite.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * 2 * delta)

	if Input.is_action_just_pressed("dash") and can_dash and not attacking:
		dashing = true
		can_dash = false
		dash_time.start()
		dash_cooldown_timer.start()
		current_state = state.dash
	move_and_slide()

func _on_dash_time_timeout() -> void:
	dashing = false
	current_state = state.idle
	set_collision_mask_value(2,true)

func _on_dash_cooldown_timer_timeout() -> void:
	can_dash = true
