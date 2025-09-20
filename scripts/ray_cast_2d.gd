extends RayCast2D 
@onready var cpu_particles_2d: CPUParticles2D = $CPUParticles2D

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
	pass

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
	$CPUParticles2D.global_position = get_collision_point()
func set_is_casting(new_value: bool):
	if is_casting == new_value:
		return
	is_casting = new_value
	set_physics_process(is_casting)

	if not is_casting:
		target_position = Vector2.ZERO


func _on_timer_timeout() -> void:
	tween = create_tween()
	tween.tween_property(line_2d, "width", 0.0,growth_time).from_current()
	tween.tween_callback(line_2d.hide)
	await get_tree().create_timer(0.2).timeout
	queue_free()
