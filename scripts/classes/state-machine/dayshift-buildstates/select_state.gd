extends StateMachineState
class_name select_state

var held_time := 0.0

var object
var current_quadrant = Vector3i.ZERO

var holding := false

var is_on_object = false

var hold_time_limit = 0.1

var debug_point = CSGSphere3D.new()


func Update(delta, machine : DayshiftManager = null):
	if machine:
		# The way this works is if the normal of the object we hit
		# is up, we can know whether it's a floor or not
		if machine.hit_normal:
			# if its vector is upward, it's a floor and we need no extra logic
			if machine.collider:
				if machine.collider.get_parent().is_in_group(&"objects"):
					is_on_object = true
					object = machine.collider
				else:
					object = null
					is_on_object = false

#func InputUpdate(event, machine : DayshiftManager):
	#if not holding:
	#	if object:
	#		machine.gizmo_box.visible = false
	#else: 
	#		# Modifying the gizmo- to represent the area
	#		# The top left corner will have the max y value and min x value
	#		# The bottom right will be the opposite
	#		
	#		# I don't fully understand how these proportions work, they just did
	#		# I had to consult someone else to figure this one out
	#		machine.gizmo_box.visible = true
	#		var start_corner := Vector2i(min(start_cell.x, machine.current_cell.x), max(start_cell.y, machine.current_cell.y))
	#		var end_corner := Vector2i(max(start_cell.x, machine.current_cell.x), min(start_cell.y, machine.current_cell.y))
	#		machine.gizmo_box.size = Vector3i(abs(end_corner.x - start_corner.x), machine.pizzeria.FLOOR_THICK, abs(start_corner.y - end_corner.y))
	#		machine.gizmo_box.size += Vector3(1, 0, 1)
	#		machine.gizmo_box.size *= Vector3(machine.pizzeria.TILE_SIZE, 1, machine.pizzeria.TILE_SIZE)
	#		machine.gizmo_box.global_position = Vector3(
	#			start_corner.x * machine.pizzeria.TILE_SIZE + machine.gizmo_box.size.x/2.0,
	#			machine.current_floor_idx * machine.pizzeria.WALL_HEIGHT,
	#			end_corner.y * machine.pizzeria.TILE_SIZE + machine.gizmo_box.size.z/2.0
	#		)
	#		if !is_floor:
	#			machine.gizmo_box.size.y = machine.pizzeria.WALL_HEIGHT
	#			machine.gizmo_box.global_position.y += machine.pizzeria.WALL_HEIGHT/2

func InputUpdate(event, machine : DayshiftManager):
	if get_viewport().gui_get_hovered_control():
			return 
			
	if Input.is_action_just_released("lclick"):
		if object:
			machine.selected_object = machine.collider.get_parent()
			machine.emit_signal(&"has_selected")


func Vec3(n):
	return Vector3(n,0,n)

func Enter(machine : DayshiftManager):
	holding = false
	held_time = 0.0
	var start_cell = Vector2i.ZERO
	machine.gizmo_level = machine.GIZMO_LEVELS.NEUTRAL
	machine.gizmo_box.visible = false
	
	add_child(debug_point)

func Exit(machine : DayshiftManager):
	holding = false
	held_time = 0.0
	var start_cell = Vector2i.ZERO
	machine.gizmo_level = machine.GIZMO_LEVELS.NEUTRAL
	machine.gizmo_box.visible = true
