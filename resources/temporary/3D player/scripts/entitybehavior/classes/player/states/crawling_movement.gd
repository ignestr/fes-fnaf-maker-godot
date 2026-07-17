extends State
class_name player_crawl_move

# References

@onready var viewport = $"../../Head/Camera3D"
@onready var collision = $"../../CollisionShape3D"
@onready var ply = $"../.."


# Variables
var canRegen = false


func Enter():
	print("entered crawl")
	viewport.position.y = 0.1
	collision.shape.height = 1
	await get_tree().create_timer(1.5)
	canRegen = true
	
func PhysicsUpdate(delta):
	ply.wasdGroundMove(ply.SPEED / 2)


func Exit():
	print("exited crawl")
	viewport.position.y = 0.689
	collision.shape.height = 2
