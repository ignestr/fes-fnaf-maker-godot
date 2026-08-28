extends Node
class_name StateMachine

var current_state : StateMachineState

@export var default_state : StateMachineState

var states : Dictionary[StringName, StateMachineState]= {}


func _ready() -> void:
	for i in get_children():
		if i is StateMachineState:
			states[StringName(i.name)] = i
	
	if default_state:
		state(default_state)
	_ready_extra()


func _ready_extra():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if current_state:
		current_state.Update(delta, self)

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.Update(delta, self)

func state(new_state : StateMachineState):
	if new_state == current_state:
		print(self.name, "attempted to switch to state", str(new_state) + ",", "but it's already the current state.")
		await current_state.Exit(self)
		await current_state.Enter(self)
		return 
	
	if current_state:
		current_state.Exit(self)
	new_state.Enter(self)
	current_state = new_state
