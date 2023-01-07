extends KinematicBody2D

var MAX_SPEED = 400
var ACCELERATION = 1700
var motion = Vector2()


func _physics_process(delta: float) -> void:
	var axis: Vector2 = get_input_axis()
	if axis == Vector2.ZERO:
		apply_friction(ACCELERATION * delta)
	else:
		apply_movement(axis * ACCELERATION * delta)
	motion = move_and_slide(motion)
	
	look_at(get_global_mouse_position())

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

