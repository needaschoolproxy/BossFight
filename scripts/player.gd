extends CharacterBody2D

@onready var dash_time: Timer = $DashTime
@onready var dash_cooldown_timer: Timer = $DashCooldownTimer
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_right: Area2D = $AttackArea_Right
@onready var attack_left: Area2D = $AttackArea_Left
@onready var attack_up: Area2D = $AttackArea_Up

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
var ATTACK_DAMAGE := 20
var ATTACK_KNOCKBACK := 400.0
var can_attack := true
const ATTACK_COOLDOWN := 0.2
var jumping := false
var attack_stage := 1

# HP
var max_health := 500
var health := 500
var displayed_health := 500
var is_hurt := false
var knockback_velocity := Vector2.ZERO
const HURT_DURATION := 0.25
const DAMAGE_COOLDOWN := 0.5
var can_take_damage := true
const HP_INTERPOLATION_SPEED := 10.0

enum state {idle, run, jump, attack, dash}
var current_state := state.idle

var hp_bar: ProgressBar = null
const RESET_KEY := KEY_R

# Attack offsets
var attack_offset_horizontal := Vector2(50, 0)
var attack_offset_up := Vector2(-10, -50) # slightly left for proper alignment

func _ready():
	# Disable hitboxes at start
	attack_right.monitoring = false
	attack_left.monitoring = false
	attack_up.monitoring = false

	_create_hp_bar()
	if not InputMap.has_action("reset_game"):
		InputMap.add_action("reset_game")
		var key_event := InputEventKey.new()
		key_event.scancode = RESET_KEY
		InputMap.action_add_event("reset_game", key_event)

func _process(delta: float) -> void:
	displayed_health = lerp(displayed_health, health, delta * HP_INTERPOLATION_SPEED)
	update_hp_bar()

	if Input.is_action_just_pressed("reset_game"):
		reset_game()

	# Animation
	match current_state:
		state.idle:
			sprite.play("Idle")
		state.run:
			sprite.play("MoveLeftRight")
		state.jump:
			sprite.play("Jump")
		state.attack:
			pass # Handled in start_attack()
		state.dash:
			sprite.play("Dash")
			set_collision_mask_value(2, false)

func _physics_process(delta: float) -> void:
	# Gravity
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

	# Jump input
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

	# Horizontal movement
	var direction := Input.get_axis("left", "right")
	if direction != 0:
		if not attacking and not dashing:
			current_state = state.run
		velocity.x = direction * (DASH_SPEED if dashing else SPEED)
		sprite.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * 2 * delta)

	# Dash
	if Input.is_action_just_pressed("dash") and can_dash and not attacking:
		dashing = true
		can_dash = false
		dash_time.start()
		dash_cooldown_timer.start()
		current_state = state.dash

	# Attack
	if Input.is_action_just_pressed("attack") and not attacking and can_attack:
		start_attack()

	# Knockback
	if knockback_velocity.length() > 10.0:
		velocity = knockback_velocity
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 1000.0 * delta)
	else:
		knockback_velocity = Vector2.ZERO

	move_and_slide()

	if health <= 0:
		reset_game()

# -----------------------
# Attack Functions
# -----------------------
func start_attack():
	attacking = true
	can_attack = false
	current_state = state.attack

	# Reset all hitboxes
	attack_right.monitoring = false
	attack_left.monitoring = false
	attack_up.monitoring = false

	# Determine attack direction
	if Input.is_action_pressed("up"):
		sprite.play("AttackUp")
		attack_up.monitoring = true
		attack_up.position = attack_offset_up
	elif sprite.flip_h:
		sprite.play("Attack" if attack_stage == 1 else "Attack2")
		attack_left.monitoring = true
		attack_left.position = attack_offset_horizontal * -1
	else:
		sprite.play("Attack" if attack_stage == 1 else "Attack2")
		attack_right.monitoring = true
		attack_right.position = attack_offset_horizontal

	# Connect body_entered if needed
	for area in [attack_right, attack_left, attack_up]:
		if not area.is_connected("body_entered", Callable(self, "_on_attack_area_body_entered")):
			area.connect("body_entered", Callable(self, "_on_attack_area_body_entered"))

	await get_tree().create_timer(0.1).timeout

	# Disable hitboxes
	attack_right.monitoring = false
	attack_left.monitoring = false
	attack_up.monitoring = false
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
		var knock_dir := -1 if sprite.flip_h else 1
		body.take_damage(ATTACK_DAMAGE, Vector2(knock_dir * ATTACK_KNOCKBACK, -200))
		velocity.x = -knock_dir * 100

# -----------------------
# Jump
# -----------------------
func trigger_jump_anim():
	jumping = true
	if sprite.animation != "Jump":
		sprite.play("Jump")

# -----------------------
# Dash
# -----------------------
func _on_dash_time_timeout() -> void:
	dashing = false
	current_state = state.idle
	set_collision_mask_value(2, true)

func _on_dash_cooldown_timer_timeout() -> void:
	can_dash = true

# -----------------------
# Damage / HP
# -----------------------
func take_damage(damage: int, knockback: Vector2):
	if not can_take_damage:
		return
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

	if health <= 0:
		reset_game()

func update_hp_bar():
	if hp_bar:
		hp_bar.value = displayed_health

func reset_game():
	get_tree().reload_current_scene()

# -----------------------
# HP Bar
# -----------------------
func _create_hp_bar():
	var canvas_layer := CanvasLayer.new()
	add_child(canvas_layer)
	canvas_layer.layer = 1

	hp_bar = ProgressBar.new()
	canvas_layer.add_child(hp_bar)
	hp_bar.min_value = 0
	hp_bar.max_value = max_health
	hp_bar.value = health
	hp_bar.size = Vector2(200, 20)
	hp_bar.position = Vector2(20, 20)

	var style_bg := StyleBoxFlat.new()
	style_bg.bg_color = Color(0.2, 0.2, 0.2)
	hp_bar.add_theme_stylebox_override("bg", style_bg)

	var style_fg := StyleBoxFlat.new()
	style_fg.bg_color = Color(0, 1, 0)
	hp_bar.add_theme_stylebox_override("fg", style_fg)

	hp_bar.add_theme_color_override("border_color", Color(1, 1, 1))
