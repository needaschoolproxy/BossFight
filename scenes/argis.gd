extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


enum state{idle,retract,lightning,glow,signaling}
var current_state = state.idle


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
		
		
