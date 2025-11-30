extends CharacterBody2D
@onready var character = get_parent().get_parent().get_node("Node2D2/CharacterBody2D")

@onready var pinbottop: Sprite2D = $Pinbottop


func _process(delta: float) -> void:
	$Pinbottop.look_at(character.position)
