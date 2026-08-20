extends StateMachineState
class_name set_material_state

var held_time := 0.0

var start_cell := Vector2i(0, 0)
var current_vertex := Vector2i.ZERO

var projected_cell:= Vector2i(0, 0)

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
		start_cell = projected_cell
	
	if machine:
		# The way this works is if the normal of the object we hit
		# is up, we can know whether it's a floor or not
		if machine.hit_normal:
			# if its vector is upward, it's a floor and we need no extra logic
			if machine.hit_normal.y > 0.9:
				is_floor = true
				projected_cell = machine.current_cell
			else:
				# if it's not, it's not a floor, defaulting to horizontal
				is_floor = false
				orientation = false
				
				var obtained_cell = Vector2i(
					floori(float(machine.hit_pos.x) / machine.pizzeria.TILE_SIZE),
					floori(float(machine.hit_pos.z) / machine.pizzeria.TILE_SIZE))
					
				var obtained_vert = Vector2i(
					roundi(float(machine.hit_pos.x) / machine.pizzeria.TILE_SIZE),
					roundi(float(machine.hit_pos.z) / machine.pizzeria.TILE_SIZE))
				
				match machine.hit_normal:
					Vector3(0,0,1):
						projected_cell = obtained_cell
					Vector3(0,0,-1):
						projected_cell = obtained_cell + Vector2i(0, 1)
					Vector3(1,0,0):
						orientation = true
						projected_cell = obtained_cell
					Vector3(-1,0,0):
						orientation = true
						projected_cell = obtained_cell + Vector2i(1, 0)
				# if it doesn't even exist
				#if !(machine.pizzeria.floors[machine.current_floor_idx].walls.has(Vector3i(projected_cell.x, projected_cell.y, orientation))):
				#	if machine.collider:
				#		orientation = !orientation
				#		projected_cell = obtained_vert
				#		if orientation:
				#			projected_cell.y -= 1
				#		else:
				#			projected_cell.x -= 1

	#if machine.mouse_coordinates:
	#	current_vertex = Vector2(
	#		roundi(float(machine.mouse_coordinates.x) / machine.pizzeria.TILE_SIZE),
	#		roundi(float(machine.mouse_coordinates.z) / machine.pizzeria.TILE_SIZE)
	#		)
	#		
	
	if Input.is_action_pressed("lclick"):
		# keep a score of how much time the key has been pressed
		if get_viewport().gui_get_hovered_control():
			return 
		held_time += delta
		
		
		# NOTE we should offload this to user preference, maybe use one global holding time window
		if held_time >= hold_time_limit:
			holding = true
	
	
	if Input.is_action_just_released("lclick") and held_time != 0:
		holding = false
		if held_time >= hold_time_limit: 
			held_time = 0
			var end_cell = projected_cell
			if is_floor and Materindex.list_all.materials[machine.current_item].is_wall_mat == false:
				machine.changemat_ground(start_cell, end_cell)
			elif Materindex.list_all.materials[machine.current_item].is_wall_mat == true:
				if start_cell == end_cell:
					machine.changemat_walls(start_cell, end_cell, orientation)
				else:
					machine.changemat_walls(start_cell, end_cell, false)
			machine.gizmo_box.visible = false

func InputUpdate(event, machine : DayshiftManager):
	if not holding:
		if is_floor:
			machine.gizmo_box.visible = true
			machine.gizmo_box.global_position = Vector3i(projected_cell.x, machine.current_floor_idx * machine.pizzeria.WALL_HEIGHT, projected_cell.y)
			machine.gizmo_box.global_position *= Vector3(machine.pizzeria.TILE_SIZE, 1, machine.pizzeria.TILE_SIZE)
			machine.gizmo_box.global_position += Vector3(machine.pizzeria.TILE_SIZE/2, 0, machine.pizzeria.TILE_SIZE/2)
			machine.gizmo_box.size = Vector3(machine.pizzeria.TILE_SIZE, machine.pizzeria.FLOOR_THICK, machine.pizzeria.TILE_SIZE)
		else:
			if orientation == false:
				machine.gizmo_box.visible = true
				machine.gizmo_box.global_position = Vector3(projected_cell.x, machine.current_floor_idx * machine.pizzeria.WALL_HEIGHT + machine.pizzeria.WALL_HEIGHT/2, projected_cell.y)
				machine.gizmo_box.global_position *= Vector3(machine.pizzeria.TILE_SIZE, 1, machine.pizzeria.TILE_SIZE)
				machine.gizmo_box.global_position.x += machine.pizzeria.TILE_SIZE/2
				machine.gizmo_box.size = Vector3(machine.pizzeria.TILE_SIZE, machine.pizzeria.WALL_HEIGHT, machine.pizzeria.WALL_THICK)
			else:
				machine.gizmo_box.visible = true
				machine.gizmo_box.global_position = Vector3(projected_cell.x, machine.current_floor_idx * machine.pizzeria.WALL_HEIGHT + machine.pizzeria.WALL_HEIGHT/2, projected_cell.y)
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
	

func Enter(machine : DayshiftManager):
	print("hi guyys")
	holding = false
	var held_time = 0.0
	var start_cell = Vector2i.ZERO
	machine.gizmo_level = machine.GIZMO_LEVELS.OTHER

func Exit(machine : DayshiftManager):
	holding = false
	var held_time = 0.0
	var start_cell = Vector2i.ZERO
	machine.gizmo_level = machine.GIZMO_LEVELS.NEUTRAL
