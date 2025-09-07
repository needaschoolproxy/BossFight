extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var marker_2d: Marker2D = $Marker2D
@onready var marker_2d_2: Marker2D = $Marker2D2
@onready var lightningcooldown: Timer = $lightningcooldown

var groundwave = preload("res://scenes/ground_wave.tscn")
var lightning = preload("res://scenes/lightning.tscn")
enum state{idle,retract,lightning,glow,signaling}
var current_state = state.idle
var retracted = false
var lightninged = false
var health = 500
var is_hurt = false
const HURT_DURATION = 0.1

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
	if health <= 0: return queue_free()
	
	if animated_sprite_2d.animation == ("retract") and animated_sprite_2d.frame == 10 and retracted == false:
		var new_wave = groundwave.instantiate()
		add_child(new_wave)
		new_wave.transform = $Marker2D.transform
		new_wave.flip = false
		retracted = true
	
	if animated_sprite_2d.animation == ("lightning") and animated_sprite_2d.frame == 11 and lightninged == false:
		var new_lightning = lightning.instantiate()
		get_parent().add_child(new_lightning)
		new_lightning.position.x = position.x + randf_range(-500,500)
		new_lightning.position.y = position.y + 125
		lightninged = true
		
func _on_area_2d_body_entered(_body: Node2D) -> void:
	current_state = state.retract


func _on_animated_sprite_2d_animation_finished() -> void:
	current_state = state.idle
	retracted = false
	lightninged = false


func _on_lightningcooldown_timeout() -> void:
	if current_state == state.idle:
		current_state = state.lightning
		
		
	
func take_damage(dmg: int, _kb: Vector2) -> void:
	health -= dmg
	is_hurt = true             
	$AnimatedSprite2D.modulate = Color(1,0.5,0.5)
	await get_tree().create_timer(HURT_DURATION).timeout
	$AnimatedSprite2D.modulate = Color(1,1,1)
	is_hurt = false
	await get_tree().create_timer(1).timeout
