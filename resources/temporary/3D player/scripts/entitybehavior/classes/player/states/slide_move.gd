extends State
class_name player_slide_move


# References
@onready var viewport = $"../../Head/Camera3D"
@onready var ply = $"../.."
@onready var fsm = $".."
@onready var collision = $"../../CollisionShape3D"

# Variables
var immediate_basis

func Enter():
	var tween = create_tween()
	
	# This is so that you can look around without changing the slide direction
	immediate_basis = ply.basis
	ply.velocity.y = 0
	await tween.tween_property(viewport, "rotation_degrees", Vector3(10, 0, 0), 0.1)
	viewport.position.y = 0.1
	collision.shape.height = 1
	

func PhysicsUpdate(delta):
	var direction = (immediate_basis * Vector3.FORWARD).normalized()
	if direction:
		ply.velocity.x = direction.x * ply.SPRINT_SPEED * 1.2
		ply.velocity.z = direction.z * ply.SPRINT_SPEED * 1.2 
	
	if ply.isMoving == false:
		fsm.state("general")
	
	
func Exit():
	var tween = create_tween()
	await tween.tween_property(viewport, "rotation_degrees", Vector3(0, 0, 0), 0.2)
	viewport.position.y = 0.689
	collision.shape.height = 2
