extends State


func enter(_msg: Dictionary = {}):
	Config.CAN_CONTROL_PLAYER = false
	_actor.blood.visible = true
	_parent.velocity = Vector2.ZERO
	_parent.enter()


func unhandled_input(event: InputEvent):
	_parent.unhandled_input(event)


func physics_process(delta: float):
	_parent.physics_process(delta)


func exit():
	Config.CAN_CONTROL_PLAYER = true
	_parent.exit()
