extends Area2D
@onready var ray_cast_2d: RayCast2D = $RayCast2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if not $RayCast2D.is_colliding():
		position.y += 1
