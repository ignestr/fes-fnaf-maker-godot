extends Node
class_name StateMachineState

func Enter():
	pass

func Exit():
	pass

## The equivalent of _process()
func Update(delta, machine):
	pass

## The equivalent of _physics_process()
func PhysicsUpdate(delta, machine):
	pass

## The equivalent of _input()
func InputUpdate(event, machine):
	pass
