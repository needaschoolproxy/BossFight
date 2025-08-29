extends CharacterBody2D

@onready var character = get_parent().get_parent().get_node("Node2D2/CharacterBody2D")


const SPEED = 200
func _process(delta: float) -> void:
	look_at(character.position)
