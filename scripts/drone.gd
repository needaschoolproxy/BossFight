extends CharacterBody2D
@onready var character_body_2d: CharacterBody2D = $"../CharacterBody2D"
var fireball = preload("res://scenes/fireball.tscn")

var health = 50
var is_hurt = false
const HURT_DURATION = 0.2

func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if health <= 0: return queue_free()
	look_at(character_body_2d.position)


func take_damage(dmg: int, _kb: Vector2) -> void:
	health -= dmg
	is_hurt = true             
	$AnimatedSprite2D.modulate = Color(1,0.5,0.5)
	await get_tree().create_timer(HURT_DURATION).timeout
	$AnimatedSprite2D.modulate = Color(1,1,1)
	is_hurt = false
	await get_tree().create_timer(1).timeout
