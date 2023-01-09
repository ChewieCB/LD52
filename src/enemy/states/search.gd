extends State

var target setget set_target


func enter(_msg: Dictionary = {}):
	target = _actor.player_last_seen_position
	_parent.velocity = Vector2.ZERO
	_parent.enter()
	_actor.draw_colour = _actor.YELLOW


func _physics_process(delta):
	if not target:
		return
	
	# Path to the target
	var nav_path = _actor.nav.get_simple_path(_actor.position, target)
	
	# Convert the path points from local space to global space for the draw func
	var path_line_points = []
	for _point in nav_path:
		var _global_point = _point - _actor.global_position
		path_line_points.append(_global_point)
	
	# Move towards the target
	# Point the viewcone towards the next point
	_actor.raycast.cast_to = nav_path[1] - _actor.global_position
	
	# Calculate the movement distance for this frame
	var distance_to_walk = _parent.move_speed * delta
	
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
	
	# When we get to the player's last known position, look around for them
	if _actor.position.distance_to(target) < 1:
		scan_area()


func scan_area():
	# Rotate the view cone a few times to check for the player
	var original_cast = _actor.raycast.cast_to
	var scan_directions = [
		deg2rad(_actor.FOV),
		deg2rad(-_actor.FOV),
	]
	# Shuffle the order of directions
	scan_directions = shuffle_array(scan_directions)
	#
	for direction in scan_directions:
		_actor.look_at(_actor.global_position + original_cast.rotated(direction))
		var wait_timer = get_tree().create_timer(rand_range(1.0, 2.0))
		yield(wait_timer, "timeout")
	
	_actor.raycast.cast_to = original_cast
	target = null
	_actor.player_last_seen_position = null
	if _actor.IS_FOLLOWING:
		_state_machine.transition_to("Movement/Follow")
	else:
		_state_machine.transition_to("Movement/Idle")


func shuffle_array(array):
	var suffled_array = []
	var index_array = range(array.size())
	for _i in range(array.size()):
		randomize()
		var x = randi() % index_array.size()
		suffled_array.append(array[x])
		index_array.remove(x)
		array.remove(x)
	return suffled_array


func set_target(value):
	target = value
	
	if not target:
		if _actor.IS_FOLLOWING:
			_state_machine.transition_to("Movement/Follow")
		else:
			_state_machine.transition_to("Movement/Idle")


func exit():
	_parent.exit()
