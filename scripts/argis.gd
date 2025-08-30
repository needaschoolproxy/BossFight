extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var marker_2d: Marker2D = $Marker2D
@onready var marker_2d_2: Marker2D = $Marker2D2

var groundwave = preload("res://scenes/ground_wave.tscn")
enum state{idle,retract,lightning,glow,signaling}
var current_state = state.idle
var retracted = false

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
	
	if animated_sprite_2d.animation == ("retract") and animated_sprite_2d.frame == 5 and retracted == false:
		var new_wave = groundwave.instantiate()
		add_child(new_wave)
		new_wave.transform = $Marker2D.transform
		retracted = true
	
		
func _on_area_2d_body_entered(_body: Node2D) -> void:
	current_state = state.retract


func _on_animated_sprite_2d_animation_finished() -> void:
	current_state = state.idle
	retracted = false
