extends KinematicBody2D
class_name Player

onready var state_machine = $StateMachine
onready var state_label = $StateLabel

onready var is_dead = false

onready var blood = $BloodSprite



func death():
	state_machine.transition_to("Movement/Death")
	is_dead = true


