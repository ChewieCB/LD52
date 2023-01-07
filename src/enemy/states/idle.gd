extends State

"""
In the Idle state a character will mill about unmoving, but keeping watch for the player
"""


func enter(_msg: Dictionary = {}):
	_parent.velocity = Vector2.ZERO
	_parent.enter()


func unhandled_input(event: InputEvent):
	_parent.unhandled_input(event)


func physics_process(delta: float):
	_parent.physics_process(delta)
	
	if _actor.IS_FOLLOWING:
		_state_machine.transition_to("Movement/Follow")


func exit():
	_parent.exit()
