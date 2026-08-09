extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@onready var dayshift_manager : DayshiftManager = $"../DayshiftManager"

func _physics_process(delta: float) -> void:
	
	var input_dir := Input.get_vector("left", "right", "fwrd", "back")
	var direction := (transform.basis *  Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	move_and_slide()


func _on_floor_button_pressed() -> void:
	dayshift_manager.state(dayshift_manager.states[&"ground_place_state"])


func _on_wall_button_pressed() -> void:
	dayshift_manager.state(dayshift_manager.states[&"wall_place_state"])


func _on_room_button_pressed() -> void:
	pass # Replace with function body.


func _on_select_button_pressed() -> void:
	pass # Replace with function body.


func _on_delete_button_pressed() -> void:
	dayshift_manager.state(dayshift_manager.states[&"delete_state"])
