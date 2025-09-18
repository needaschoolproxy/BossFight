extends CharacterBody2D

@onready var dash_time: Timer = $DashTime
@onready var dash_cooldown_timer: Timer = $DashCooldownTimer
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_right: Area2D = $AttackArea_Right
@onready var attack_left: Area2D = $AttackArea_Left
@onready var attack_up: Area2D = $AttackArea_Up
@onready var attack_down: Area2D = $AttackArea_Down


var SPEED := 450.0
const JUMP_VELOCITY := -900.0
const GRAVITY := 2000.0
const FAST_FALL_MULTIPLIER := 2.0
const JUMP_CUT_MULTIPLIER := 0.5
var doublejumped := false
const DASH_SPEED := 1200
var dashing := false
var can_dash := true
var attacking := false
var ATTACK_DAMAGE := 200
var ATTACK_KNOCKBACK := 400.0
var can_attack := true
const ATTACK_COOLDOWN := 0.2
var jumping := false
var attack_stage := 1

var max_health := 100
var health := 100
var displayed_health := 100
var is_hurt := false
var knockback_velocity := Vector2.ZERO
const HURT_DURATION := 0.25
const DAMAGE_COOLDOWN := 0.5
var can_take_damage := true

enum state {idle, run, jump, attack, dash}
var current_state := state.idle

var hp_bar: ProgressBar = null
const RESET_KEY := KEY_R

func _ready():
	for area in [attack_right, attack_left, attack_up, attack_down]:
		area.monitoring = false
	if not InputMap.has_action("reset_game"):
		InputMap.add_action("reset_game")
		var key_event := InputEventKey.new()
		key_event.scancode = RESET_KEY
		InputMap.action_add_event("reset_game", key_event)
	if not sprite.is_connected("animation_finished", Callable(self, "_on_animation_finished")):
		sprite.connect("animation_finished", Callable(self, "_on_animation_finished"))


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("reset_game"):
		reset_game()
	match current_state:
		state.idle: sprite.play("Idle")
		state.run: sprite.play("MoveLeftRight")
		state.jump: sprite.play("Jump")
		state.attack: pass
		state.dash:
			sprite.play("Dash")
			set_collision_mask_value(2, false)
			set_collision_layer_value(3, false)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * (FAST_FALL_MULTIPLIER if velocity.y > 0 else 1) * delta
		if current_state not in [state.attack, state.dash]:
			current_state = state.jump
	else:
		doublejumped = false
		if current_state not in [state.attack, state.dash]:
			current_state = state.idle
		velocity.y = 0
		jumping = false

	if Input.is_action_just_pressed("jump"):
		if is_on_floor() or not doublejumped:
			velocity.y = JUMP_VELOCITY
			if not is_on_floor(): doublejumped = true
			trigger_jump_anim()

	if not Input.is_action_pressed("jump") and velocity.y < 0:
		velocity.y *= JUMP_CUT_MULTIPLIER

	var direction := Input.get_axis("left", "right")
	if direction != 0:
		if not attacking and not dashing: current_state = state.run
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

	if knockback_velocity.length() > 10.0:
		velocity = knockback_velocity
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 1000.0 * delta)
	else:
		knockback_velocity = Vector2.ZERO

	move_and_slide()
	if health <= 0: reset_game()

func start_attack():
	attacking = true
	can_attack = false
	current_state = state.attack

	for area in [attack_right, attack_left, attack_up, attack_down]:
		area.monitoring = false

	if Input.is_action_pressed("up"):
		sprite.play("AttackUp")
		attack_up.monitoring = true
	elif Input.is_action_pressed("down") and not is_on_floor():
		sprite.play("AttackDown")
		attack_down.monitoring = true
	elif sprite.flip_h:
		sprite.play("Attack" if attack_stage == 1 else "Attack2")
		attack_left.monitoring = true
	else:
		sprite.play("Attack" if attack_stage == 1 else "Attack2")
		attack_right.monitoring = true

	for area in [attack_right, attack_left, attack_up, attack_down]:
		if not area.is_connected("body_entered", Callable(self, "_on_attack_area_body_entered")):
			area.connect("body_entered", Callable(self, "_on_attack_area_body_entered"))

	await get_tree().create_timer(0.12).timeout

	for area in [attack_right, attack_left, attack_up, attack_down]:
		area.monitoring = false

	attacking = false
	attack_stage = 2 if attack_stage == 1 else 1
	current_state = state.idle if is_on_floor() else state.jump
	await get_tree().create_timer(ATTACK_COOLDOWN).timeout
	can_attack = true

func _on_attack_area_body_entered(body):
	if body.has_method("take_damage"):
		var knock_dir := -1 if sprite.flip_h else 1
		if attack_up.monitoring or attack_left.monitoring or attack_right.monitoring:
			body.take_damage(ATTACK_DAMAGE, Vector2(knock_dir * ATTACK_KNOCKBACK, -200))
			velocity.x = -knock_dir * 100
		elif attack_down.monitoring:
			body.take_damage(ATTACK_DAMAGE, Vector2(0, 200))
			velocity.y = JUMP_VELOCITY * randf_range(8,12)

func _on_animation_finished():
	var anim_name := sprite.animation
	if attacking and (anim_name == "Attack" or anim_name == "Attack2" or anim_name == "AttackUp" or anim_name == "AttackDown"):
		sprite.play(anim_name)

func trigger_jump_anim():
	jumping = true
	if sprite.animation != "Jump": sprite.play("Jump")

func _on_dash_time_timeout() -> void:
	dashing = false
	current_state = state.idle
	set_collision_mask_value(2, true)
	set_collision_layer_value(3, true)
func _on_dash_cooldown_timer_timeout() -> void:
	can_dash = true

func take_damage(damage: int, knockback: Vector2):
	if not can_take_damage: return
	health -= damage
	is_hurt = true
	can_take_damage = false
	knockback_velocity = knockback

	var original_modulate := sprite.modulate
	sprite.modulate = Color(1, 0.5, 0.5)
	await get_tree().create_timer(HURT_DURATION).timeout
	sprite.modulate = original_modulate
	is_hurt = false
	await get_tree().create_timer(DAMAGE_COOLDOWN).timeout
	can_take_damage = true

	if health <= 0: reset_game()

func reset_game():
	get_tree().reload_current_scene()
