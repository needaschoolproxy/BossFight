extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var ground_wave_timer: Timer = $GroundWaveTimer
@onready var marker_2d: Marker2D = $Marker2D

var groundwave = preload("res://scenes/ground_wave.tscn")
enum state{idle,retract,lightning,glow,signaling}
var current_state = state.idle
var animation_played = false

func _process(_delta: float) -> void:
	match current_state:
		state.idle:
			animated_sprite_2d.play("idle")
		state.retract:
			if animation_played == false:
				animated_sprite_2d.play("retract")
				animation_played = true
		state.lightning:
			animated_sprite_2d.play("lightning")
		state.glow:
			animated_sprite_2d.play("glow")
		state.signaling:
			animated_sprite_2d.play("Signal")
		
		
func _on_area_2d_body_entered(_body: Node2D) -> void:
	current_state = state.retract
	$GroundWaveTimer.start()


#func _on_ground_wave_timer_timeout() -> void:
	#var new_wave = groundwave.instantiate()
	#add_child(new_wave)
	#new_wave.transform = $Marker2D.transform
