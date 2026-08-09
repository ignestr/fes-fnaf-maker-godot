extends StateMachine
class_name DayshiftManager

@export var pizzeria: MasterPizzeria
# enum states {PLACING, SELECT, ROOM, WALL}

## Variable storing the cell the mouse is on.
var current_cell : Vector2i = Vector2i(0, 0)

## Floor currently being edited as an index from pizzeria's floors array
var current_floor_idx = 0 

var gizmo_box := CSGBox3D.new()


@onready var camera = get_viewport()


var mouse_coordinates

# NOTE: cell index coordinates can be roughly defined as m/TS, where TS is
# the tile size, so in order to use them for positioning, you must ALWAYS
# multiply them by the tile size to get meters back


func _ready_extra():
	gizmo_box.size = Vector3(pizzeria.TILE_SIZE, pizzeria.FLOOR_THICK, pizzeria.TILE_SIZE)
	gizmo_box.material = load("uid://dcaedodw0xujq")
	self.add_child(gizmo_box)

func _input(event):
	# getting absolute / world space coords
	# don't ask me how it works it's old code from back when this was a mall game
	var mouse_pos = camera.get_mouse_position()
	var origin = camera.get_camera_3d().project_ray_origin(mouse_pos)
	var dir = camera.get_camera_3d().project_ray_normal(mouse_pos)
	var plane_y = float(current_floor_idx * pizzeria.WALL_HEIGHT)
	mouse_coordinates = Plane(Vector3(0, 1, 0), plane_y).intersects_ray(origin, dir)
	
	# converting to tile space
	if mouse_coordinates:
		current_cell = Vector2i(floori(float(mouse_coordinates.x) / pizzeria.TILE_SIZE), floori(float(mouse_coordinates.z) / pizzeria.TILE_SIZE))
	
	
	# state machine code
	if current_state:
		current_state.InputUpdate(event, self)


#TODO: make this use chunks
func place_floortile_single(idx : Vector2i):
	var template = pizzeria_room.new()
	pizzeria.floors[current_floor_idx].groundtiles.get_or_add(idx, template)
	pizzeria.render_base_fullfloor(pizzeria.floors[current_floor_idx], 0)

func place_floortile_range(idx_begin : Vector2i, idx_end : Vector2i):
	var template = pizzeria_room.new()
	var x_step = 1
	var y_step = 1
	
	# in case it has to step backwards in order to progress to the desired tile
	if idx_begin.x > idx_end.x:
		x_step = -1
	if idx_begin.y > idx_end.y:
		y_step = -1
	
	var chunks = []
	# going through the square
	# adding x and y step because ranges are exclusive
	for x in range(idx_begin.x, idx_end.x + x_step, x_step):
		for y in range(idx_begin.y, idx_end.y + y_step, y_step):
			pizzeria.floors[current_floor_idx].groundtiles.get_or_add(Vector2i(x, y), template)
			if not chunks.has(pizzeria.to_chunk(Vector2i(x, y))):
				chunks.append(pizzeria.to_chunk(Vector2i(x, y)))
			

	# this will tally up all chunks that should be re-rendered
	for chunk in chunks:
		pizzeria.render_chunk(chunk, pizzeria.floors[current_floor_idx], current_floor_idx * pizzeria.WALL_HEIGHT)

func place_walltile_range(idx_begin, idx_end, direction):
	var template = pizzeria_wall.new()
	template.base_set_type(pizzeria_wall.WALL_TYPES.FLAT)
	var step = 1
	
	var chunks = []
	
	# if it's a horizontal wall
	if direction == false:
		# in case it has to step backwards in order to progress to the desired tile
		var given_range = range(idx_begin.x, idx_end.x+step, step)
		if idx_begin.x > idx_end.x:
			step = -1
			given_range = range(idx_begin.x + step, idx_end.x, step)
			
		for i in given_range:
			pizzeria.floors[current_floor_idx].walls.get_or_add(Vector3i(i, idx_begin.y, 0), template)
			
			if not chunks.has(pizzeria.to_chunk(Vector2i(i, idx_begin.y))):
				chunks.append(pizzeria.to_chunk(Vector2i(i, idx_begin.y)))
	
	# if it's a vertical wall
	else:
		# in case it has to step backwards in order to progress to the desired tile
		var given_range = range(idx_begin.y, idx_end.y+step, step)
		if idx_begin.y > idx_end.y:
			step = -1
			given_range = range(idx_begin.y + step, idx_end.y, step)
		
		for i in given_range:
			pizzeria.floors[current_floor_idx].walls.get_or_add(Vector3i(idx_begin.x, i, 1), template)
			
			if not chunks.has(pizzeria.to_chunk(Vector2i(idx_begin.x, i))):
				chunks.append(pizzeria.to_chunk(Vector2i(idx_begin.x, i)))
	
	for chunk in chunks:
		pizzeria.render_chunk(chunk, pizzeria.floors[current_floor_idx], current_floor_idx * pizzeria.WALL_HEIGHT)
