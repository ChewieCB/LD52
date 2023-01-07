extends State
# Parent state for all movement-related states
# Holds all of the base movement logic
# Child states can override this states's functions or change its properties
# This keeps the logic grouped in one location

# These should be fallback defaults
# TODO: Make these null and raise an exception to indicate bad State extension
#       to better separate movement vars.
export var max_speed = 380
export var move_speed = 190

var velocity := Vector2.ZERO
var input_direction = Vector2.ZERO


func physics_process(delta: float):
	# Movement
	input_direction = get_input_direction()
	
	velocity = calculate_velocity(velocity, input_direction, delta)
	velocity = _actor.move_and_slide(velocity)


func get_input_direction():
	return Vector2.ZERO


func calculate_velocity(velocity_current: Vector2, input_dir: Vector2, delta: float):
	var velocity_new = input_dir * move_speed
	if velocity_new.length() > max_speed:
		velocity_new = velocity_new.normalized() * max_speed
	
	return velocity_new
