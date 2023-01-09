extends State

"""
In the Idle state a character will... TODO
"""


func enter(_msg: Dictionary = {}):
	_parent.velocity = Vector2.ZERO
	_parent.enter()
	
	_actor.attack_timer.start()
	_actor.FOV = 120
	_actor.draw_colour = _actor.BLUE


func unhandled_input(event: InputEvent):
	_parent.unhandled_input(event)


func physics_process(delta: float):
	if _actor.target:
		if _actor.position.distance_to(_actor.target.position) > 48:
			yield(get_tree().create_timer(0.3), "timeout")
			_state_machine.transition_to("Movement/Chase")
		
	_parent.physics_process(delta)


func exit():
	_actor.attack_timer.stop()
	_actor.FOV = 80
	_parent.exit()


func _on_AttackTimer_timeout():
	if _actor.target:
		_actor.target.death()
	_state_machine.transition_to("Movement/Idle")
