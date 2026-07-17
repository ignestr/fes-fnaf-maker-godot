extends State
class_name player_general_move


# References
@onready var viewport = $"../../Head/Camera3D"
@onready var ply = $"../.."

# Variables
var canRegen = false

func Enter():
	var tween = create_tween()
	await tween.tween_property(viewport, "fov", 75, 0.1)
	await get_tree().create_timer(1.5)
	canRegen = true

func PhysicsUpdate(delta):
	if Input.is_action_just_pressed("jump") and ply.is_on_floor():
		ply.velocity.y = ply.JUMP_VELOCITY
	ply.wasdGroundMove()
	
