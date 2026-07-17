extends State
class_name player_sprint_move

# References
@onready var viewport = $"../../Head/Camera3D"
@onready var fsm = $".."
@onready var ply = $"../.."

func Enter():
	if ply.isMoving:
		var tween = create_tween()
		await tween.tween_property(viewport, "fov", 100, 0.1)

func PhysicsUpdate(delta):
	if Input.is_action_just_pressed("jump") and ply.is_on_floor():
		ply.velocity.y = ply.JUMP_VELOCITY
	ply.wasdGroundMove(ply.SPRINT_SPEED)
	if ply.isMoving:
		var tween = create_tween()
		await tween.tween_property(viewport, "fov", 100, 0.1)
	else:
		var tween = create_tween()
		await tween.tween_property(viewport, "fov", 75, 0.1)

func Update(delta):
	if ply.isMoving == false and roundf((ply.get_real_velocity().x * ply.get_real_velocity().z)) == 0:
		fsm.state("general")

func Exit():
	pass
