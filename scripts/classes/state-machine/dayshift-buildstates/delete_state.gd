extends StateMachineState
class_name delete_state

var held_time := 0.0

var start_cell := Vector2i(0, 0)
var current_vertex := Vector2i.ZERO

var modified_mousecoords
var current_u_wall

var holding := false

var is_floor = true
# horizontal if false, vertical if true
var orientation = false

var hold_time_limit = 0.1

# TODO: make this logic be skippable if hovering over an object (as we can
# just check for those. Wait until objects are implemented)

func Update(delta, machine : DayshiftManager = null):
	
	if held_time < hold_time_limit:
		if machine:
			# The way this works is if the normal of the object we hit
			# is up, we can know 
			if machine.hit_normal:
				# if its vector is upward, it's a floor and we need no extra logic
				if machine.hit_normal.y > 0.9:
					is_floor = true
					start_cell = machine.current_cell
				else:
					# if it's not, it's not a floor, defaulting to horizontal
					is_floor = false
					orientation = false
					
					var obtained_cell = Vector2i(
						floori(float(machine.hit_pos.x) / machine.pizzeria.TILE_SIZE),
						floori(float(machine.hit_pos.z) / machine.pizzeria.TILE_SIZE))
					match machine.hit_normal:
						Vector3(0,0,1):
							start_cell = obtained_cell
						Vector3(0,0,-1):
							start_cell = obtained_cell + Vector2i(0, 1)
						Vector3(1,0,0):
							orientation = true
							start_cell = obtained_cell
						Vector3(-1,0,0):
							orientation = true
							start_cell = obtained_cell + Vector2i(1, 0)
	
	#if machine.mouse_coordinates:
	#	current_vertex = Vector2(
	#		roundi(float(machine.mouse_coordinates.x) / machine.pizzeria.TILE_SIZE),
	#		roundi(float(machine.mouse_coordinates.z) / machine.pizzeria.TILE_SIZE)
	#		)
	#		
	
	if Input.is_action_pressed("lclick"):
		# keep a score of how much time the key has been pressed
		held_time += delta
		
		
		# NOTE we should offload this to user preference, maybe use one global holding time window
		if held_time >= hold_time_limit:
			holding = true
	
	
	if Input.is_action_just_released("lclick") and held_time != 0:
		holding = false
		if held_time >= hold_time_limit:
			held_time = 0
			var end_cell = machine.current_cell
			if is_floor:
				machine.delete_floortile_range(start_cell, end_cell)
			else:
				machine.delete_wall_range(start_cell, end_cell)

func InputUpdate(event, machine : DayshiftManager):
	if not holding:
		if is_floor:
			machine.gizmo_box.global_position = Vector3i(start_cell.x, machine.current_floor_idx * machine.pizzeria.WALL_HEIGHT, start_cell.y)
			machine.gizmo_box.global_position *= Vector3(machine.pizzeria.TILE_SIZE, 1, machine.pizzeria.TILE_SIZE)
			machine.gizmo_box.global_position += Vector3(machine.pizzeria.TILE_SIZE/2, 0, machine.pizzeria.TILE_SIZE/2)
			machine.gizmo_box.size = Vector3(machine.pizzeria.TILE_SIZE, machine.pizzeria.FLOOR_THICK, machine.pizzeria.TILE_SIZE)
		else:
			if orientation == false:
				machine.gizmo_box.global_position = Vector3(start_cell.x, machine.current_floor_idx * machine.pizzeria.WALL_HEIGHT + machine.pizzeria.WALL_HEIGHT/2, start_cell.y)
				machine.gizmo_box.global_position *= Vector3(machine.pizzeria.TILE_SIZE, 1, machine.pizzeria.TILE_SIZE)
				machine.gizmo_box.global_position.x += machine.pizzeria.TILE_SIZE/2
				machine.gizmo_box.size = Vector3(machine.pizzeria.TILE_SIZE, machine.pizzeria.WALL_HEIGHT, machine.pizzeria.WALL_THICK)
			else:
				machine.gizmo_box.global_position = Vector3(start_cell.x, machine.current_floor_idx * machine.pizzeria.WALL_HEIGHT + machine.pizzeria.WALL_HEIGHT/2, start_cell.y)
				machine.gizmo_box.global_position *= Vector3(machine.pizzeria.TILE_SIZE, 1, machine.pizzeria.TILE_SIZE)
				machine.gizmo_box.global_position.z += machine.pizzeria.TILE_SIZE/2
				machine.gizmo_box.size = Vector3(machine.pizzeria.WALL_THICK, machine.pizzeria.WALL_HEIGHT, machine.pizzeria.TILE_SIZE)
	else: 
			# Modifying the gizmo- to represent the area
			# The top left corner will have the max y value and min x value
			# The bottom right will be the opposite
			
			# I don't fully understand how these proportions work, they just did
			# I had to consult someone else to figure this one out
			var start_corner := Vector2i(min(start_cell.x, machine.current_cell.x), max(start_cell.y, machine.current_cell.y))
			var end_corner := Vector2i(max(start_cell.x, machine.current_cell.x), min(start_cell.y, machine.current_cell.y))
			machine.gizmo_box.size = Vector3i(abs(end_corner.x - start_corner.x), machine.pizzeria.FLOOR_THICK, abs(start_corner.y - end_corner.y))
			machine.gizmo_box.size += Vector3(1, 0, 1)
			machine.gizmo_box.size *= Vector3(machine.pizzeria.TILE_SIZE, 1, machine.pizzeria.TILE_SIZE)
			machine.gizmo_box.global_position = Vector3(
				start_corner.x * machine.pizzeria.TILE_SIZE + machine.gizmo_box.size.x/2.0,
				machine.current_floor_idx * machine.pizzeria.WALL_HEIGHT,
				end_corner.y * machine.pizzeria.TILE_SIZE + machine.gizmo_box.size.z/2.0
			)
			if !is_floor:
				machine.gizmo_box.size.y = machine.pizzeria.WALL_HEIGHT
				machine.gizmo_box.global_position.y += machine.pizzeria.WALL_HEIGHT/2
	
