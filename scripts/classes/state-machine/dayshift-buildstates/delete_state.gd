extends StateMachineState
class_name delete_state

var held_time := 0.0

var start_cell := Vector2i(0, 0)
var start_quadrant = Vector3i.ZERO
var current_quadrant = Vector3i.ZERO

var projected_cell:= Vector2i(0, 0)

var holding := false

var is_floor = true
var is_on_object = false

# horizontal if false, vertical if true
var orientation = false

var hold_time_limit = 0.1

var debug_point = CSGSphere3D.new()

func Update(delta, machine : DayshiftManager = null):
	if held_time < hold_time_limit:
		start_cell = projected_cell
	
	if machine:
		# The way this works is if the normal of the object we hit
		# is up, we can know whether it's a floor or not
		if machine.hit_normal:
			# if its vector is upward, it's a floor and we need no extra logic
			if machine.collider:
				if machine.collider.get_parent().is_in_group(&"objects"):
					is_on_object = true
					start_quadrant = machine.collider.get_parent().index
				else:
					is_on_object = false
		
			if is_on_object == false:
				if machine.hit_normal.y == 1:
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
	
	
	if Input.is_action_pressed("lclick"):
		# keep a score of how much time the key has been pressed
		held_time += delta
		
		if get_viewport().gui_get_hovered_control():
			return 
		
		# NOTE we should offload this to user preference, maybe use one global holding time window
		if !is_on_object:
			if held_time >= hold_time_limit:
				holding = true
	
	
	if Input.is_action_just_released("lclick") and held_time != 0:
		holding = false
		if is_on_object:
			var field = DayshiftManager.fields.OBJECT_GROUND
			match Objex.list_all.objects[machine.current_item].allowed_position:
				ObjectIndexDataEntry.allowed_positions.GROUND:
					field = DayshiftManager.fields.OBJECT_GROUND
				ObjectIndexDataEntry.allowed_positions.WALL:
					field = DayshiftManager.fields.OBJECT_WALL
				ObjectIndexDataEntry.allowed_positions.ROOF:
					field = DayshiftManager.fields.OBJECT_ROOF
			machine.delete_object(start_quadrant, field)
			machine.gizmo_box.visible = false
			return
		
		if held_time >= hold_time_limit:
			held_time = 0
			var end_cell = projected_cell
			if !is_on_object:
				if is_floor:
					machine.delete_floortile_range(start_cell, end_cell)
				else:
					machine.delete_wall_range(start_cell, end_cell, orientation)
			#else:
				#end_cell = Vector3i(machine.current_cell.x, machine.current_cell.y, int(current_quadrant))
				#var field = DayshiftManager.fields.OBJECT_GROUND
				#
				#match Objex.list_all.objects[machine.current_item].allowed_position:
					#ObjectIndexDataEntry.allowed_positions.GROUND:
						#field = DayshiftManager.fields.OBJECT_GROUND
					#ObjectIndexDataEntry.allowed_positions.WALL:
						#field = DayshiftManager.fields.OBJECT_WALL
					#ObjectIndexDataEntry.allowed_positions.ROOF:
						#field = DayshiftManager.fields.OBJECT_ROOF
				#debug_point.global_position = Vector3(start_quadrant.x, 0, start_quadrant.y) * machine.pizzeria.TILE_SIZE + Vec3(machine.pizzeria.TILE_SIZE/2)
				#machine.delete_object_range(start_quadrant, end_cell, field)
			machine.gizmo_box.visible = false

func InputUpdate(event, machine : DayshiftManager):
	if not holding:
		if !is_on_object:
			if is_floor:
				machine.gizmo_box.visible = true
				#region basic position
				machine.gizmo_box.global_position = Vector3i(projected_cell.x, machine.current_floor_idx * machine.pizzeria.WALL_HEIGHT, projected_cell.y)
				machine.gizmo_box.global_position *= Vector3(machine.pizzeria.TILE_SIZE, 1, machine.pizzeria.TILE_SIZE)
				machine.gizmo_box.global_position += Vector3(machine.pizzeria.TILE_SIZE/2, 0, machine.pizzeria.TILE_SIZE/2)
				#endregion
				machine.gizmo_box.size = Vector3(machine.pizzeria.TILE_SIZE, machine.pizzeria.FLOOR_THICK, machine.pizzeria.TILE_SIZE)
			else:
				if orientation == false:
					machine.gizmo_box.visible = true
					#region basic position
					machine.gizmo_box.global_position = Vector3(projected_cell.x, machine.current_floor_idx * machine.pizzeria.WALL_HEIGHT + machine.pizzeria.WALL_HEIGHT/2, projected_cell.y)
					machine.gizmo_box.global_position *= Vector3(machine.pizzeria.TILE_SIZE, 1, machine.pizzeria.TILE_SIZE)
					machine.gizmo_box.global_position.x += machine.pizzeria.TILE_SIZE/2
					#endregion
					machine.gizmo_box.size = Vector3(machine.pizzeria.TILE_SIZE, machine.pizzeria.WALL_HEIGHT, machine.pizzeria.WALL_THICK)
				else:
					machine.gizmo_box.visible = true
					machine.gizmo_box.global_position = Vector3(projected_cell.x, machine.current_floor_idx * machine.pizzeria.WALL_HEIGHT + machine.pizzeria.WALL_HEIGHT/2, projected_cell.y)
					machine.gizmo_box.global_position *= Vector3(machine.pizzeria.TILE_SIZE, 1, machine.pizzeria.TILE_SIZE)
					machine.gizmo_box.global_position.z += machine.pizzeria.TILE_SIZE/2
					machine.gizmo_box.size = Vector3(machine.pizzeria.WALL_THICK, machine.pizzeria.WALL_HEIGHT, machine.pizzeria.TILE_SIZE)
		else:
			machine.gizmo_box.visible = false
	else: 
			# Modifying the gizmo- to represent the area
			# The top left corner will have the max y value and min x value
			# The bottom right will be the opposite
			
			# I don't fully understand how these proportions work, they just did
			# I had to consult someone else to figure this one out
			machine.gizmo_box.visible = true
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
	

func Vec3(n):
	return Vector3(n,0,n)

func Enter(machine : DayshiftManager):
	holding = false
	var held_time = 0.0
	var start_cell = Vector2i.ZERO
	machine.gizmo_level = machine.GIZMO_LEVELS.NEGATIVE
	add_child(debug_point)

func Exit(machine : DayshiftManager):
	holding = false
	var held_time = 0.0
	var start_cell = Vector2i.ZERO
	machine.gizmo_level = machine.GIZMO_LEVELS.NEUTRAL
