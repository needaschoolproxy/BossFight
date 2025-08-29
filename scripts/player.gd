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
const ATTACK_COOLDOWN = 0.2
var jumping = false
var attack_stage = 1

enum state {idle, run, jump, attack, dash}
var current_state = state.idle

func _ready():
	attack_area.collision_mask = 1 << 1
	attack_area.monitoring = false

func _process(delta: float) -> void:
	match current_state:
		state.idle:
			sprite.play("Idle")
		state.run:
			sprite.play("MoveLeftRight")
		state.jump:
			sprite.play("Jump")
		state.attack:
			if attack_stage == 1 and sprite.animation != "Attack":
				sprite.play("Attack")
			elif attack_stage == 2 and sprite.animation != "Attack2":
				sprite.play("Attack2")
		state.dash:
			sprite.play("Dash")
			set_collision_mask_value(2, false)

	if not is_on_floor():
		if velocity.y > 0:
			velocity.y += GRAVITY * FAST_FALL_MULTIPLIER * delta
		else:
			velocity.y += GRAVITY * delta
		if current_state != state.attack and current_state != state.dash:
			current_state = state.jump
	else: 
		doublejumped = false
		if current_state != state.attack and current_state != state.dash:
			current_state = state.idle
		velocity.y = 0
		if jumping:
			jumping = false

	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
			trigger_jump_anim()
		elif not doublejumped:
			velocity.y = JUMP_VELOCITY
			doublejumped = true
			trigger_jump_anim()

	if not Input.is_action_pressed("jump") and velocity.y < 0:
		velocity.y *= JUMP_CUT_MULTIPLIER

	var direction := Input.get_axis("left", "right")
	if direction != 0:
		if not attacking and not dashing:
			current_state = state.run
		velocity.x = direction * (DASH_SPEED if dashing else SPEED)
		sprite.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * 2 * delta)

	if Input.is_action_just_pressed("dash") and can_dash and not attacking:
		dashing = true
		can_dash = false
		dash_time.start()
		dash_cooldown_timer.start()
		current_state = state.dash

	if Input.is_action_just_pressed("attack") and not attacking and can_attack:
		start_attack()

	move_and_slide()

func start_attack():
	attacking = true
	can_attack = false
	current_state = state.attack

	var base_offset_x = 50
	attack_area.position.x = abs(base_offset_x)
	attack_area.scale.x = 1 if not sprite.flip_h else -1

	if attack_stage == 1:
		sprite.play("Attack")
	else:
		sprite.play("Attack2")

	attack_area.monitoring = true
	$AttackArea/CollisionShape2D.disabled = false

	if not attack_area.is_connected("body_entered", Callable(self, "_on_attack_area_body_entered")):
		attack_area.connect("body_entered", Callable(self, "_on_attack_area_body_entered"))

	await get_tree().create_timer(0.1).timeout

	attack_area.monitoring = false
	$AttackArea/CollisionShape2D.disabled = true
	attacking = false

	attack_stage = 2 if attack_stage == 1 else 1

	if is_on_floor():
		current_state = state.idle
	elif velocity.y != 0:
		current_state = state.jump

	await get_tree().create_timer(ATTACK_COOLDOWN).timeout
	can_attack = true

func _on_attack_area_body_entered(body):
	if body.has_method("take_damage"):
		var knock_dir = -1 if sprite.flip_h else 1
		body.take_damage(ATTACK_DAMAGE, Vector2(knock_dir * ATTACK_KNOCKBACK, -200))
		velocity.x = -knock_dir * 100

func trigger_jump_anim():
	jumping = true
	if sprite.animation != "Jump":
		sprite.play("Jump")

func _on_dash_time_timeout() -> void:
	dashing = false
	current_state = state.idle
	set_collision_mask_value(2, true)

func _on_dash_cooldown_timer_timeout() -> void:
	can_dash = true
