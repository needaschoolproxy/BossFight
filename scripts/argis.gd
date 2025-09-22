extends CharacterBody2D

@onready var texture_progress_bar: CanvasLayer = $TextureProgressBar
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
const DRONE = preload("uid://cckilbnu307qv")


enum state {idle, retract, lightning, glow, signaling, secondphase }
var current_state = state.idle
var retracted = false
var lightninged = false
var health = 1500
var is_hurt = false
const HURT_DURATION = 0.1
var secondphase = false
var laseractive = false

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	if follow_area.overlaps_body($"../CharacterBody2D"):
		$TextureProgressBar.visible = true
	else: $TextureProgressBar.visible = false
	
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
		var lightning_count = randi_range(4, 5) if secondphase else randi_range(2, 3)
		for i in range(lightning_count):
			var new_lightning = LIGHTNING.instantiate()
			owner.add_child(new_lightning)
			new_lightning.position.x = position.x + randf_range(-500, 500)
			new_lightning.position.y = position.y + 125
			lightninged = true
			await get_tree().create_timer(0.2).timeout
		


func _on_retract_area_body_entered(_body: Node2D) -> void:
	$retracttimer.start()

func _on_retract_area_body_exited(_body: Node2D) -> void:
	$retracttimer.start()
	$retracttimer.stop()

func _on_animated_sprite_2d_animation_finished() -> void:
	if health <= 800 and not secondphase:
		current_state = state.secondphase
		await get_tree().create_timer(1.6).timeout
		secondphase = true
	else: if not current_state == state.glow:
		current_state = state.idle
	retracted = false
	lightninged = false

func _on_lightningcooldown_timeout() -> void:
	if current_state == state.idle and follow_area.overlaps_body($"../CharacterBody2D") and laseractive == false:
		current_state = state.lightning

func take_damage(dmg: int, _kb: Vector2) -> void:
	health -= dmg
	is_hurt = true
	$AnimatedSprite2D.modulate = Color(1.25, 0.5, 0.5)
	await get_tree().create_timer(HURT_DURATION).timeout
	$AnimatedSprite2D.modulate = Color(1.0, 1.0, 1.0, 1.0)
	is_hurt = false
	await get_tree().create_timer(1.35).timeout

func _on_retracttimer_timeout() -> void:
	if laseractive == false:
		await animated_sprite_2d.animation_finished
		current_state = state.retract

func _on_laser_timer_timeout() -> void:
	await animated_sprite_2d.animation_finished
	if secondphase == true:
		current_state = state.glow
		await get_tree().create_timer(0.2).timeout
		laseractive = true
		var new_laser = LASER.instantiate()
		var new_laser_2 = LASER.instantiate()
		add_child(new_laser)
		current_state = state.glow
		new_laser.global_position = lasermarker.global_position
		await get_tree().create_timer(1).timeout
		current_state = state.glow
		add_child(new_laser_2)
		new_laser_2.global_position = lasermarker.global_position
		await get_tree().create_timer(5).timeout
		laseractive = false
		current_state = state.idle
	else:
		current_state = state.glow
		await get_tree().create_timer(0.2).timeout
		laseractive = true
		var new_laser = LASER.instantiate()
		add_child(new_laser)
		current_state = state.glow
		new_laser.global_position = lasermarker.global_position
		await get_tree().create_timer(5).timeout
		laseractive = false
		current_state = state.idle

	if secondphase:
		laser_timer.wait_time = randf_range(9, 10.5)
	else:
		laser_timer.wait_time = randf_range(12.0, 14.0)


func _on_drone_summon_timeout() -> void:
	pass
	#if secondphase == true: 
		#await animated_sprite_2d.animation_finished
		#current_state = state.signaling
		#await get_tree().create_timer(0.5).timeout
		#var new_drone = DRONE.instantiate()
		#add_child(new_drone)
