extends Node
## Class that handles storing the pizzeria's data, rendering it as a 3D object and editing efficiently. 
class_name master_pizzeria

## Array that holds each floor. Each floor
var floors = []
## Most likely deprecated, might use later on.
@export var SIZE : Vector2i = Vector2i(20, 20)
## The size of each tile in standard position units. Uses an int for simplicity.
@export var TILE_SIZE : int = 3
## The global height all walls use in standard position units. Uses an int for simplicity.
@export var WALL_HEIGHT : int = 5
## The global width all walls use in standard position units. Keep it at low values.
@export var WALL_THICK : float = 0.2
var animatronics = []


func _ready():
	pass

## 
func init_pizzeria():
	# counter for the amount of floors present
	if floors.size() == 0:
		floors.append(pizzeria_floor.new())
	else:
		for i in floors:
			render(i, 0, )

## Instance CSG pizzeria fully, then bake.
# Needs work with the chunking system that I'll implement soon
func render(floor : pizzeria_floor, floor_level, idx=0):
	
	# If there is no CSGCombiner3D present,
	if !self.has_node("pizzeria_csg"):
		var newcsg = CSGCombiner3D.new()
		newcsg.name = "pizzeria_csg"
		newcsg.use_collision = true
		add_child(newcsg)
	
	var csg = self.get_node("pizzeria_csg")
	print(csg)
	
	# God give me strength
	
	# 1: handling floors
	for i in floor.rooms:
		var room = CSGBox3D.new()
		room.size = Vector3(TILE_SIZE, 0.1, TILE_SIZE)
		room.global_position = Vector3(i.x * TILE_SIZE, floor_level, i.y * TILE_SIZE)
		#INFO x is temporarily negative because the debug editor is flipped for whatever reason
		csg.add_child(room)
	
	#2: walls
	for i in floor.walls:
		var wall = CSGBox3D.new()
		if floor.walls[i].base_get_type() != pizzeria_wall.WALL_TYPES.NONE:
			if i.z == 0: # 0 if the wall is horizontal like ---, and 1 if it's vertical like |
				# Adjust size according to orientation
				wall.size = Vector3(WALL_THICK, WALL_HEIGHT, TILE_SIZE)
				# Position math for converting from tile space to world space w/ tile size
				wall.position = Vector3(i.x * TILE_SIZE - TILE_SIZE/2 - WALL_THICK*2, floor_level+WALL_HEIGHT/2, i.y * TILE_SIZE)
			else:
				# Adjust size according to orientation
				wall.size = Vector3(TILE_SIZE, WALL_HEIGHT, WALL_THICK)
				# Position math for converting from tile space to world space w/ tile size
				wall.position = Vector3(i.x * TILE_SIZE, floor_level+WALL_HEIGHT/2, i.y * TILE_SIZE - TILE_SIZE/2 - WALL_THICK*2)
			# after the wall is set up, instance the basic wall
			csg.add_child(wall)
			# if the wall doesn't need a cutout for windows, doors etc, the loop ends here
			# if not, it uses csg to make one
			if floor.walls[i].base_get_type() != pizzeria_wall.WALL_TYPES.FLAT:
				# wow we have so many colors ALERT BUG NOTE INFO
				# you should use them here is the link:
				# https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html#comments
				var cutout = CSGBox3D.new()
				cutout.operation = CSGShape3D.OPERATION_SUBTRACTION
				# different cutout positions and dimensions for each type
				match floor.walls[i].base_get_type():
					pizzeria_wall.WALL_TYPES.DOOR:
						cutout.position = wall.position
						#TODO: finish the logic, and CRITICAL ly, make the models for the devices 
						
				# instance the final cutout, end wall loop
				csg.add_child(cutout)
	
func _process(delta: float) -> void:
	pass
