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

var MAX_SPEED = 400
var ACCELERATION = 1700
var motion = Vector2()


func physics_process(delta: float) -> void:
	# Debug Reset
	if Input.is_action_pressed("reset"):
		var _ret = get_tree().reload_current_scene()
	elif Input.is_action_pressed("quit"):
		get_tree().quit()
	
	if Config.CAN_CONTROL_PLAYER:
		var axis: Vector2 = get_input_axis()
		if axis == Vector2.ZERO:
			_state_machine.transition_to("Movement/Idle")
			apply_friction(ACCELERATION * delta)
		else:
			_state_machine.transition_to("Movement/Move")
			apply_movement(axis * ACCELERATION * delta)
		motion = _actor.move_and_slide(motion)
		
		_actor.look_at(_actor.get_global_mouse_position())


func get_input_axis() -> Vector2:
	var axis: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	return axis.normalized()


func apply_friction(amount: float) -> void:
	if motion.length() > amount:
		motion -= motion.normalized() * amount
	else:
		motion = Vector2.ZERO


func apply_movement(acceleration):
	motion += acceleration
	motion = motion.clamped(MAX_SPEED)

