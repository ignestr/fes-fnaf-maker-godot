extends StateMachineState
class_name wall_place_state

var held_time := 0.0
var start_cell := Vector2i(0, 0)

var holding := false
var hold_time_limit = 0.3


var current_wall := Vector2i.ZERO
var end_cell := Vector2i.ZERO

# Whether the wall currently being drawn by the user
# is vertical (like |) or horizontal (like ---) from a top-down view
var vertical := false
@onready var camera = get_viewport()

func Update(delta, machine : DayshiftManager = null):
	
	# Walls lie at the vertices of tiles
	# This is fundamentally a different metric than current_cell
	# so we have to calculate this
	
		
	if machine.mouse_coordinates:
		current_wall = Vector2(
			roundi(float(machine.mouse_coordinates.x) / machine.pizzeria.TILE_SIZE),
			roundi(float(machine.mouse_coordinates.z) / machine.pizzeria.TILE_SIZE)
			)
	
	if held_time < hold_time_limit:
		if machine:
			start_cell = current_wall
	
	# converting back to global by multiplying by the tile size and adding half the tile size
	# done in multiple steps for readiblity
	if Input.is_action_pressed("lclick"):
		# keep a score of how much time the key has been pressed
		held_time += delta
		if get_viewport().gui_get_hovered_control():
			return 
		
		# NOTE we should offload this to user preference, maybe use one global holding time window
		if held_time >= hold_time_limit:
			holding = true
		# if you're not on the holding period yet 
	
	
	
	if Input.is_action_just_released("lclick") and held_time != 0:
		holding = false
		if held_time > hold_time_limit:
			held_time = 0
			# the cell that we end off on
			var req_end_wall = current_wall
			
			# false if it's horizontal, true if it's vertical
			vertical = false
			
			# Given the two points, we have to find out whether to make
			# a vertical or horizontal wall, as well as the actual end cell
			# This is because while the line between start_cell and end_cell
			# could have any direction, the grid only supports straight walls
			#
			# The way this is done is by first making the vector start at zero,
			# then determining the longer component to be the direction
			#
			# Finally, if it's vertical we replace the x component of the end_cell
			# Conversely, if it's horizontal we replace the y
			# This aligns the wall's end with the appropiate straight line
			# (default to horizontal if it's diagonal)
			
			# First, we make it start at the origin by subtracting the
			# endpoint by the start point 
			var fixed_vector = Vector2i(
				req_end_wall.x - start_cell.x,
				req_end_wall.y - start_cell.y
			)
			
			# If dragging within one tile, it will just work with the mouse's
			# actual position
			if fixed_vector == Vector2i.ZERO:
				fixed_vector = Vector2(
					machine.mouse_coordinates.x - start_cell.x + machine.pizzeria.TILE_SIZE/2,
					machine.mouse_coordinates.y - start_cell.y + machine.pizzeria.TILE_SIZE/2
				)
				
			
			
			# Then, now that the direction can be expressed as one vector,
			# we can just check which side is longer
			if abs(fixed_vector.y) > abs(fixed_vector.x):
				vertical = true
			
			var end_cell = req_end_wall
			
			# align the cells 
			if vertical == false:
				end_cell.y = start_cell.y
			else:
				end_cell.x = start_cell.x
					
			machine.place_walltile_range(start_cell, end_cell - Vector2i.ONE, vertical)



func InputUpdate(event, machine : DayshiftManager):
	var req_end_wall = current_wall
	
	# false if it's horizontal, true if it's vertical
	vertical = false
	
	# Given the two points, we have to find out whether to make
	# a vertical or horizontal wall, as well as the actual end cell
	# This is because while the line between start_cell and end_cell
	# could have any direction, the grid only supports straight walls
	#
	# The way this is done is by first making the vector start at zero,
	# then determining the longer component to be the direction
	#
	# Finally, if it's vertical we replace the x component of the end_cell
	# Conversely, if it's horizontal we replace the y
	# This aligns the wall's end with the appropiate straight line
	# (default to horizontal if it's diagonal)
	
	# First, we make it start at the origin by subtracting the
	# endpoint by the start point 
	var fixed_vector = Vector2i(
		req_end_wall.x - start_cell.x,
		req_end_wall.y - start_cell.y
	)
	
	# If dragging within one tile, it will just work with the mouse's
	# actual position
	if fixed_vector == Vector2i.ZERO:
		if machine.mouse_coordinates:
			fixed_vector = Vector2(
				machine.mouse_coordinates.x - start_cell.x + machine.pizzeria.TILE_SIZE/2,
				machine.mouse_coordinates.y - start_cell.y + machine.pizzeria.TILE_SIZE/2
			)
		else:
			return
	
	
	# Then, now that the direction can be expressed as one vector,
	# we can just check which side is longer
	if abs(fixed_vector.y) > abs(fixed_vector.x):
		vertical = true
	
	var end_cell = req_end_wall
	
	# align the cells 
	if vertical == false:
		end_cell.y = start_cell.y
	else:
		end_cell.x = start_cell.x
	
	if not holding:
		machine.gizmo_box.size = Vector3(machine.pizzeria.WALL_THICK, machine.pizzeria.WALL_HEIGHT, machine.pizzeria.WALL_THICK)
		machine.gizmo_box.global_position = Vector3(
			current_wall.x,
			machine.current_floor_idx * machine.pizzeria.WALL_HEIGHT + machine.pizzeria.WALL_HEIGHT/2,
			current_wall.y
			)
		machine.gizmo_box.global_position *= Vector3(
			machine.pizzeria.TILE_SIZE,
			1, 
			machine.pizzeria.TILE_SIZE
			)
	else:
		if vertical == false:
			machine.gizmo_box.size = Vector3(
				# The length of the line
				abs((end_cell - start_cell).x) * machine.pizzeria.TILE_SIZE,
				machine.pizzeria.WALL_HEIGHT,
				machine.pizzeria.WALL_THICK
				)
			
				
			machine.gizmo_box.global_position = Vector3(
				start_cell.x * machine.pizzeria.TILE_SIZE + machine.gizmo_box.size.x/2.0,
				machine.current_floor_idx * machine.pizzeria.WALL_HEIGHT + machine.pizzeria.WALL_HEIGHT/2,
				start_cell.y * machine.pizzeria.TILE_SIZE
			)
			if (end_cell - start_cell).x < 0:
				machine.gizmo_box.global_position.x = start_cell.x * machine.pizzeria.TILE_SIZE - machine.gizmo_box.size.x/2.0
			
		else:
			machine.gizmo_box.size = Vector3(
				# The length of the line
				machine.pizzeria.WALL_THICK,
				machine.pizzeria.WALL_HEIGHT,
				abs((end_cell - start_cell).y) * machine.pizzeria.TILE_SIZE
				)
				
			machine.gizmo_box.global_position = Vector3(
				start_cell.x * machine.pizzeria.TILE_SIZE,
				machine.current_floor_idx * machine.pizzeria.WALL_HEIGHT + machine.pizzeria.WALL_HEIGHT/2 - machine.pizzeria.FLOOR_THICK*2,
				start_cell.y * machine.pizzeria.TILE_SIZE + machine.gizmo_box.size.z/2.0,
				)
			if (end_cell - start_cell).y < 0:
				machine.gizmo_box.global_position.z = start_cell.y * machine.pizzeria.TILE_SIZE - machine.gizmo_box.size.z/2.0
			
	return


func Enter(machine : DayshiftManager):
	holding = false
	var held_time = 0.0
	var start_cell = Vector2i.ZERO
	machine.gizmo_level = machine.GIZMO_LEVELS.POSITIVE

func Exit(machine : DayshiftManager):
	holding = false
	var held_time = 0.0
	var start_cell = Vector2i.ZERO
	machine.gizmo_level = machine.GIZMO_LEVELS.NEUTRAL
