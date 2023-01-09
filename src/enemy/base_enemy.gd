extends KinematicBody2D

export var nav_path := NodePath()
onready var nav = get_node(nav_path)

export var follow_route_path := NodePath()
onready var follow_route = get_node(follow_route_path)

onready var raycast = $RayCast2D
var space_state

var state_machine
var state_label

onready var audio_manager = null

var target

onready var detection_area_shape = $DetectionArea/CollisionShape2D.shape
onready var attack_area = $AttackArea

onready var attack_timer = $AttackTimer

const cell_size = 32
const cell_size_vector = Vector2(32, 32)
export (int) var DETECT_RADIUS = 512
export (int) var NEAR_RADIUS = 64
export (int) var VERY_NEAR_RADIUS = 64
var player_last_seen_position
export (int) var view_angle setget set_view_angle
export (int) var FOV = 80
var view_cone_points setget set_view_cone_points
var view_cone_points_colors

var orig_position: Vector2
var orig_rotation: float
var last_position: Vector2
var last_rotation: float

# Behaviour flags
export var IS_HOSTILE = true
export var IS_FOLLOWING = false


func _ready():
	state_machine = $StateMachine
	state_label = $StateLabel
	orig_position = self.global_position
	orig_rotation = self.global_rotation

# Drawing the FOV
const RED = Color(1.0, 0, 0, 0.4)
const GREEN = Color(0, 1.0, 0, 0.4)
const YELLOW = Color(1.0, 1.0, 0, 0.4)
const BLUE = Color(0, 10, 1.0, 0.4)
var draw_colour = GREEN

func _physics_process(_delta):
	space_state = get_world_2d().direct_space_state
	var view_cone = gen_circle_arc_poly(cell_size_vector/2, DETECT_RADIUS, view_angle - FOV/2, view_angle + FOV/2)
	view_cone_points = view_cone[0]
	view_cone_points_colors = view_cone[1]


func _process(_delta):
	update()


func _draw():
	if view_cone_points:
		draw_polygon(view_cone_points, PoolColorArray([draw_colour]))
	if player_last_seen_position:
		draw_circle(to_local(player_last_seen_position + cell_size_vector / 2), 3, Color(0, 0, 1, 0.5))
#	draw_circle(Vector2.ZERO, NEAR_RADIUS * cell_size, Color(0.6, 0, 0.7, 0.4))
#	draw_circle(Vector2.ZERO, VERY_NEAR_RADIUS * cell_size, Color(1, 1, 1, 0.4))


func gen_circle_arc_poly(center, radius, angle_from, angle_to):
	var nb_points = 32
	var points_arc = PoolVector2Array()
	var colors = PoolColorArray()
	points_arc.push_back(center)
	colors.push_back(GREEN)
	
	for i in range(nb_points + 1):
		var angle_point = angle_from + i * (angle_to - angle_from) / nb_points
		var _point = center + Vector2(cos(deg2rad(angle_point)), sin(deg2rad(angle_point))) * radius
		# Check if the point collides with anything
		var result = space_state.intersect_ray(to_global(center), to_global(_point), [self, target], 1)
		if result:
			# Add the point where the ray collides
			points_arc.push_back(to_local(result.position))
			colors.push_back(RED)
		else:
			# Add the point as normal
			points_arc.push_back(_point)
			colors.push_back(GREEN)
	set_view_cone_points(points_arc)
	return [points_arc, colors]


func set_view_angle(value):
	view_angle = value
	var new_cast = raycast.cast_to.rotated(deg2rad(value))
	raycast.cast_to = new_cast
	raycast.force_raycast_update()


func set_view_cone_points(value):
	view_cone_points = value
	# FIXME - this shape isn't drawing correctly
	var new_view_shape = ConvexPolygonShape2D.new()
	new_view_shape.points = (view_cone_points)
	$DetectionArea/CollisionShape2D.shape = new_view_shape


func _on_DetectionArea_body_entered(body):
	if body is Player and IS_HOSTILE:
		if not body.is_dead:
			draw_colour = RED
			if not target:
				target = body
				last_position = self.global_position
				last_rotation = self.global_rotation
				state_machine.transition_to("Movement/Chase")


func _on_DetectionArea_body_exited(body):
	if body is Player:
		if not body.is_dead and body == target:
			target = null
			draw_colour = GREEN
			player_last_seen_position = body.global_position
			if state_machine.state == $StateMachine/Movement/Chase:
				state_machine.transition_to("Movement/Search")

