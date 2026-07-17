extends State
class_name straight_float_behavior

# References
@onready var ply = $"../.."


func Enter():
	ply.motion_mode = ply.MOTION_MODE_FLOATING
	
func Update(delta):
	var camera = get_viewport().get_camera_3d()
	var camera_basis = camera.global_transform.basis
	
	var move_input = Input.get_vector("left", "right", "fwrd", "back")
	if not move_input.is_zero_approx() and not ply.onTask:
		ply.velocity = Vector3() # reset velocity as below will process it further
		ply.velocity += move_input.y * camera_basis.z * ply.FLOAT_SPEED
		ply.velocity += move_input.x * camera_basis.x * ply.FLOAT_SPEED
	elif not ply.onTask:
		ply.velocity = Vector3()
	if Input.is_action_pressed("jump") and not ply.onTask:
		ply.velocity.y += 5

func Exit():
	ply.motion_mode = ply.MOTION_MODE_GROUNDED
