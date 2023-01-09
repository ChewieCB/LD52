extends State

"""
In the Idle state a character will mill about unmoving, but keeping watch for the player
"""


func enter(_msg: Dictionary = {}):
	_parent.velocity = Vector2.ZERO
	_parent.enter()
	_actor.draw_colour = _actor.GREEN


func unhandled_input(event: InputEvent):
	_parent.unhandled_input(event)


func physics_process(delta: float):
	_parent.physics_process(delta)
	
	# Return to the enemy's initial position before idling or resuming follow path
	if _actor.last_position and _actor.global_position != _actor.last_position:
		# Determine where to send the enemy back to
		var target_position: Vector2
		var target_rotation: float
		match _actor.IS_FOLLOWING:
			true:
				target_position = _actor.last_position
				target_rotation = _actor.last_rotation
			false:
				target_position = _actor.orig_position
				target_rotation = _actor.orig_rotation
		
		# Path to the target
		var nav_path = _actor.nav.get_simple_path(_actor.position, target_position)
		
		# Convert the path points from local space to global space for the draw func
		var path_line_points = []
		for _point in nav_path:
			var _global_point = _point - _actor.global_position
			path_line_points.append(_global_point)
		
		# Move towards the target
		# Point the viewcone towards the next point
		_actor.raycast.cast_to = nav_path[1] - _actor.global_position
		
		# Calculate the movement distance for this frame
		var distance_to_walk = _parent.move_speed * 1.4 * delta
		
		# Move the player along the path until he has run out of movement or the path ends.
		while distance_to_walk > 0 and nav_path.size() > 0:
			_actor.look_at(nav_path[0])
			var distance_to_next_point = _actor.position.distance_to(nav_path[0])
			if distance_to_walk <= distance_to_next_point:
				# The player does not have enough movement left to get to the next point.
				_actor.position += _actor.position.direction_to(nav_path[0]) * distance_to_walk
			else:
				# The player get to the next point
				_actor.position = nav_path[0]
				nav_path.remove(0)
			# Update the distance to walk
			distance_to_walk -= distance_to_next_point
		
		# Reset the rotation at the end of the movement
		if distance_to_walk >= 0 and nav_path.size() <= 0:
			_actor.global_rotation = target_rotation
	
	if _actor.IS_FOLLOWING:
		_state_machine.transition_to("Movement/Follow")


func exit():
	_parent.exit()
