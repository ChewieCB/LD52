extends State

""" 
"""

var target
var follow_path
var path_points
var follow_path_index = 0


func enter(_msg: Dictionary = {}):
	_parent.velocity = Vector2.ZERO
	_parent.enter()
	
	follow_path = _actor.follow_route
	path_points = follow_path.curve.get_baked_points()
	var path_points_array = Array(path_points)
#	var closest_point = follow_path.curve.get_closest_point(_actor.position)
#	var target_index = path_points_array.find(closest_point)
#	var remaining_path_points = path_points_array.slice(target_index, path_points_array.size())


func physics_process(_delta: float):
	# FIXME - the index breaks at the end of the path loop
	# Path to the target
	target = path_points[follow_path_index]
	var nav_path = _actor.nav.get_simple_path(_actor.position, target)
	
	# Convert the path points from local space to global space for the draw func
	var path_line_points = []
	for _point in nav_path:
		var _global_point = _point - _actor.global_position
		path_line_points.append(_global_point)
	var path_line = _actor.get_node("Line2D")
	path_line.points = path_line_points
	
	# Move towards the target
	# Point the viewcone towards the next point
	_actor.raycast.cast_to = nav_path[1] - _actor.global_position
	
	# Calculate the movement distance for this frame
	var distance_to_walk = _parent.move_speed * _delta
	
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
	
		if _actor.global_position.distance_to(target) < _actor.cell_size:
			if follow_path_index >= path_points.size() - 1:
				follow_path_index = 0
			else:
				follow_path_index += 1


func exit():
	_parent.exit()

