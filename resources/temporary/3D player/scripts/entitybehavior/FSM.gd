extends Node
class_name FSM
@onready var autocompleteTester = $".."
@export var spawnstate : State
var cur_state
var old_state

# https://www.youtube.com/watch?v=i0Y6anqiJ-g

var states = {}

func _ready():
	# Fill up the states automatically
	for child in self.get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.state_transition
			
	if spawnstate:
		spawnstate.Enter()
		old_state = spawnstate
		cur_state = spawnstate

func state(desired, origin = "unknown"):
	old_state.Exit()
	if states.has(desired) and desired != null:
		var newState = states[desired]
		newState.Enter()
		old_state = newState
		cur_state = newState
	else:
		print("THERE IS NO " + str(desired) + " STATE BITCH. Coming from " + str(origin))
	
func _process(delta):
	cur_state.Update(delta)

func _physics_process(delta):
	cur_state.PhysicsUpdate(delta)
