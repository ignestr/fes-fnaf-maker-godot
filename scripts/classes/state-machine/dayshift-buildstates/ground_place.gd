extends StateMachineState
class_name ground_place_state

var held_time := 0.0
var start_cell := Vector2i(0, 0)

var holding := false

var hold_time_limit = 0.1


func Update(delta, machine : DayshiftManager = null):
	
	# converting back to global by multiplying by the tile size and adding half the tile size
	# done in multiple steps for readiblity
	if Input.is_action_pressed("lclick"):
		# keep a score of how much time the key has been pressed
		held_time += delta
		
		
		# NOTE we should offload this to user preference, maybe use one global holding time window
		if held_time >= hold_time_limit:
			holding = true
		# if you're not on the holding period yet 
		else:
			if machine:
				start_cell = machine.current_cell
	
	if Input.is_action_just_released("lclick") and held_time != 0:
		holding = false
		if held_time >= hold_time_limit:
			held_time = 0
			var end_cell = machine.current_cell
			if start_cell == end_cell:
				single_click(machine)
			machine.place_floortile_range(start_cell, end_cell)
		else:
			single_click(machine)

# Helper function
func single_click(machine):
	held_time = 0
	machine.place_floortile_single(start_cell)

func InputUpdate(event, machine):
	if not holding:
		machine.gizmo_box.global_position = Vector3i(machine.current_cell.x, machine.current_floor_idx * machine.pizzeria.WALL_HEIGHT, machine.current_cell.y)
		machine.gizmo_box.global_position *= Vector3(machine.pizzeria.TILE_SIZE, 1, machine.pizzeria.TILE_SIZE)
		machine.gizmo_box.global_position += Vector3(machine.pizzeria.TILE_SIZE/2, 0, machine.pizzeria.TILE_SIZE/2)
		machine.gizmo_box.size = Vector3(machine.pizzeria.TILE_SIZE, machine.pizzeria.FLOOR_THICK, machine.pizzeria.TILE_SIZE)
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
	pass 
