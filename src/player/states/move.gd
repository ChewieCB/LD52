extends State


func enter(_msg: Dictionary = {}):
	_parent.velocity = Vector2.ZERO
	_parent.enter()


func unhandled_input(event: InputEvent):
	_parent.unhandled_input(event)


func physics_process(delta: float):
	_parent.physics_process(delta)


func exit():
	_parent.exit()
