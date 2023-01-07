extends KinematicBody2D

export var nav_path := NodePath()
onready var nav = get_node(nav_path)

export var follow_route_path := NodePath()
onready var follow_route = get_node(follow_route_path)

onready var raycast = $RayCast2D

var state_machine
var state_label

onready var audio_manager = null

var target

onready var detection_area_shape = $DetectionArea/CollisionShape2D.shape
onready var stop_area_shape = $StopArea/CollisionShape2D.shape

const cell_size = 32
export (int) var DETECT_RADIUS = 6
export (int) var NEAR_RADIUS = 2
export (int) var VERY_NEAR_RADIUS = 2

# Behaviour flags
export var IS_HOSTILE = true
export var IS_FOLLOWING = false


func _ready():
	state_machine = $StateMachine
	state_label = $StateLabel
	detection_area_shape.radius = DETECT_RADIUS * cell_size
	stop_area_shape = NEAR_RADIUS * cell_size


# Drawing the FOV
const RED = Color(1.0, 0, 0, 0.4)
const GREEN = Color(0, 1.0, 0, 0.4)
var draw_colour = GREEN

func _draw():
	# DEBUG - draw the detection radiuses
	draw_circle(Vector2.ZERO, NEAR_RADIUS * cell_size, Color(0.6, 0, 0.7, 0.4))
	draw_circle(Vector2.ZERO, VERY_NEAR_RADIUS * cell_size, Color(1, 1, 1, 0.4))
	draw_circle(Vector2.ZERO, DETECT_RADIUS * cell_size, draw_colour)


func _on_DetectionArea_body_entered(body):
	if body is Player and IS_HOSTILE:
		draw_colour = RED
		if not target:
			target = body
			state_machine.transition_to("Movement/Chase")


func _on_DetectionArea_body_exited(body):
	if body is Player:
		if body == target:
			target = null
			draw_colour = GREEN
			state_machine.transition_to("Movement/Idle")


func _on_StopArea_body_entered(body):
	if body is Player and IS_HOSTILE:
		if body == target:
			target = null
			draw_colour = GREEN
			state_machine.transition_to("Movement/Idle")


func _on_StopArea_body_exited(body):
	if body is Player and IS_HOSTILE:
		draw_colour = RED
		if not target:
			target = body
			state_machine.transition_to("Movement/Chase")

