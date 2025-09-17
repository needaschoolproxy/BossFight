extends RayCast2D 

@onready var line_2d: Line2D = $Line2D
@export var cast_speed := 2000
@export var max_length := 1500
@export var growth_time := 0.1
@export var line_width := 0.5
@export var damage := 10
@export var knockback := Vector2.ZERO

var tween: Tween = null
var is_casting := false: set = set_is_casting

func _ready() -> void:
	appear() 

func _process(delta: float) -> void:
	target_position.x = move_toward(target_position.x, max_length, cast_speed * delta)

	var laser_end_position := target_position
	force_raycast_update()
	if is_colliding():
		laser_end_position = to_local(get_collision_point())
		var collider = get_collider()
		if collider and collider.has_method("take_damage"):
			collider.take_damage(damage, knockback)

	line_2d.points[1] = laser_end_position
	rotation_degrees += 1

func set_is_casting(new_value: bool):
	if is_casting == new_value:
		return
	is_casting = new_value
	set_physics_process(is_casting)

	if not is_casting:
		target_position = Vector2.ZERO
		dissapear()
	else:
		appear()

func appear():
	line_2d.visible = true
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween()
	tween.tween_property(line_2d,"width",line_width,growth_time * 2).from(1)

	
	var timer := Timer.new()
	timer.wait_time = 5.0
	timer.one_shot = true
	add_child(timer)
	timer.start()
	timer.timeout.connect(queue_free)

func dissapear():
	queue_free()
