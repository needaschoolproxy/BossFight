extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var marker_2d: Marker2D = $Marker2D
@onready var marker_2d_2: Marker2D = $Marker2D2
@onready var lightningcooldown: Timer = $lightningcooldown
@onready var follow_area: Area2D = $"Follow Area"
@onready var character_body_2d: CharacterBody2D = $"../CharacterBody2D"
@onready var retracttimer: Timer = $retracttimer
@onready var laser_timer: Timer = $LaserTimer
@onready var lasermarker: Marker2D = $Lasermarker

const GROUND_WAVE = preload("uid://drvmc8vusgft8")
const LIGHTNING = preload("uid://r54vgnokvpri")
const LASER = preload("uid://dd2ncwt7q3t87")

enum state { idle, retract, lightning, glow, signaling, secondphase }
var current_state = state.idle
var retracted = false
var lightninged = false
var health = 1000
var is_hurt = false
const HURT_DURATION = 0.1
var secondphase = false
var using_laser := false
var active_lasers: Array = []

func _ready() -> void:
	laser_timer.wait_time = randf_range(5.0, 9.0)
	laser_timer.start()

func _process(_delta: float) -> void:
	match current_state:
		state.idle:
			animated_sprite_2d.play("idle")
		state.retract:
			animated_sprite_2d.play("retract")
		state.lightning:
			animated_sprite_2d.play("lightning")
		state.glow:
			animated_sprite_2d.play("glow")
		state.signaling:
			animated_sprite_2d.play("Signal")
		state.secondphase:
			animated_sprite_2d.play("2ndphase")

	if health <= 0:
		queue_free()
		return

	if animated_sprite_2d.animation == "retract" and animated_sprite_2d.frame == 10 and not retracted:
		if using_laser: return
		var wave_right = GROUND_WAVE.instantiate()
		add_child(wave_right)
		wave_right.transform = marker_2d.transform
		wave_right.flip = false
		var wave_left = GROUND_WAVE.instantiate()
		add_child(wave_left)
		wave_left.transform = marker_2d_2.transform
		wave_left.flip = true
		retracted = true

	if animated_sprite_2d.animation == "lightning" and animated_sprite_2d.frame == 11 and not lightninged:
		if using_laser: return
		var lightning_count = randi_range(4, 5) if secondphase else randi_range(2, 3)
		for i in range(lightning_count):
			var new_lightning = LIGHTNING.instantiate()
			owner.add_child(new_lightning)
			new_lightning.position.x = position.x + randf_range(-500, 500)
			new_lightning.position.y = position.y + 125
			lightninged = true
			await get_tree().create_timer(0.2).timeout

func _on_retract_area_body_entered(_body: Node2D) -> void:
	if using_laser: return
	$retracttimer.start()

func _on_retract_area_body_exited(_body: Node2D) -> void:
	if using_laser: return
	$retracttimer.start()
	$retracttimer.stop()

func _on_animated_sprite_2d_animation_finished() -> void:
	if health <= 500 and not secondphase:
		current_state = state.secondphase
		await get_tree().create_timer(1.6).timeout
		secondphase = true
		laser_timer.wait_time *= 0.75
	else:
		current_state = state.idle
	retracted = false
	lightninged = false

func _on_lightningcooldown_timeout() -> void:
	if using_laser: return
	if current_state == state.idle and follow_area.overlaps_body($"../CharacterBody2D"):
		current_state = state.lightning

func take_damage(dmg: int, _kb: Vector2) -> void:
	health -= dmg
	is_hurt = true
	$AnimatedSprite2D.modulate = Color(1, 0.5, 0.5)
	await get_tree().create_timer(HURT_DURATION).timeout
	$AnimatedSprite2D.modulate = Color(1.0, 1.0, 1.0, 1.0)
	is_hurt = false
	await get_tree().create_timer(1.35).timeout

func _on_retracttimer_timeout() -> void:
	if using_laser: return
	await animated_sprite_2d.animation_finished
	current_state = state.retract

func _on_laser_timer_timeout() -> void:
	if current_state == state.idle and not using_laser:
		await animated_sprite_2d.animation_finished
		current_state = state.glow
		using_laser = true
		await animated_sprite_2d.animation_finished

		var pizza_angles = [deg_to_rad(120), deg_to_rad(240), deg_to_rad(360)]
		if secondphase:
			active_lasers.clear()
			for angle in pizza_angles:
				var new_laser = LASER.instantiate()
				add_child(new_laser)
				new_laser.global_position = lasermarker.global_position
				new_laser.global_rotation = lasermarker.global_rotation + angle
				active_lasers.append(new_laser)
				new_laser.tree_exited.connect(func():
					active_lasers.erase(new_laser)
					if active_lasers.is_empty():
						using_laser = false
						current_state = state.idle
				)
		else:
			var new_laser = LASER.instantiate()
			add_child(new_laser)
			new_laser.global_position = lasermarker.global_position
			new_laser.global_rotation = lasermarker.global_rotation
			active_lasers = [new_laser]
			new_laser.tree_exited.connect(func():
				active_lasers.erase(new_laser)
				using_laser = false
				current_state = state.idle
			)

	if secondphase:
		laser_timer.wait_time = randf_range(2.5, 4.5)
	else:
		laser_timer.wait_time = randf_range(5.0, 9.0)
	laser_timer.start()
