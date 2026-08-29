extends StateMachineState
class_name delete_state

var start_cell := Vector2i(0, 0)
var end_cell

var start_wall := Vector2i(0,0)
var end_wall

var current_quadrant = Vector3i.ZERO

var projected_cell:= Vector2i(0, 0)
var projected_wall := Vector2i(0,0)


var is_floor = true
var is_on_object = false

var object_node

# horizontal if false, vertical if true
var orientation = false
var start_orientation = false
var end_orientation = false

var removing_wall = false

#var debug_point = CSGSphere3D.new()

func Update(delta, machine : DayshiftManager = null):
	if machine:
		# The way this works is if the normal of the object we hit
		# is up, we can know whether it's a floor or not
		if machine.hit_normal:
			# if its vector is upward, it's a floor and we need no extra logic
			if machine.collider:
				if machine.collider.get_parent().is_in_group(&"objects"):
					is_on_object = true
					object_node = machine.collider.get_parent()
					machine.gizmo_box.visible = false
				else:
					is_on_object = false
					machine.gizmo_box.visible = true
			if is_on_object == false:
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
					var obtained_wall = Vector2i(
						floori(float(machine.hit_pos.x) / machine.pizzeria.TILE_SIZE),
						floori(float(machine.hit_pos.z) / machine.pizzeria.TILE_SIZE))
					
					match machine.hit_normal:
						Vector3(0,0,1):
							projected_cell = obtained_cell
							projected_wall = obtained_wall
						Vector3(0,0,-1):
							projected_cell = obtained_cell + Vector2i(0, 1)
							projected_wall = obtained_wall + Vector2i(0, 1)
						Vector3(1,0,0):
							orientation = true
							projected_cell = obtained_cell
							projected_wall = obtained_wall
						Vector3(-1,0,0):
							orientation = true
							projected_cell = obtained_cell + Vector2i(1, 0)
							projected_wall = obtained_wall + Vector2i(1, 0)
	
	if get_viewport().gui_get_hovered_control():
			return
	if Input.is_action_just_pressed("lclick"):
		start_cell = projected_cell
		start_wall = projected_wall
		start_orientation = orientation
		if !is_floor:
			removing_wall = true
		else:
			removing_wall = false
	
	if Input.is_action_pressed("lclick"):
		end_cell = projected_cell
		end_wall = projected_wall
	else:
		end_wall = null
		end_cell = null
	
	if Input.is_action_just_released("lclick"):
		if get_viewport().gui_get_hovered_control():
			return 
		
		if is_on_object and object_node:
			if object_node is WallDevice:
				machine.delete_walldevice(object_node.index)
				return
			if !object_node.is_on_anchor:
				machine.delete_object(object_node.index, object_node.field)
				machine.gizmo_box.visible = false
				return
			else:
				machine.delete_object_anchor(object_node.index, object_node.anchor_number, object_node.field)
				machine.gizmo_box.visible = false
				return
		var end_cell = projected_cell
		var end_wall = projected_wall
		if !is_on_object:
			if is_floor:
				machine.delete_floortile_range(start_cell, end_cell)
			else:
				if start_orientation == orientation:
					machine.delete_wall_range(start_wall, projected_wall, orientation)
				else:
					machine.delete_wall_range(start_wall, projected_wall, 2)
		
		#else: Removed until further notice
		#	end_cell = Vector3i(machine.current_cell.x, machine.current_cell.y, 0)
		#	var field = DayshiftManager.fields.OBJECT_GROUND
		#	
		#	match Objex.list_all.objects[machine.current_item].allowed_position:
		#		ObjectIndexDataEntry.allowed_positions.GROUND:
		#			field = DayshiftManager.fields.OBJECT_GROUND
		#		ObjectIndexDataEntry.allowed_positions.WALL:
		#			field = DayshiftManager.fields.OBJECT_WALL
		#		ObjectIndexDataEntry.allowed_positions.ROOF:
		#			field = DayshiftManager.fields.OBJECT_ROOF
		#	#debug_point.global_position = Vector3(start_quadrant.x, 0, start_quadrant.y) * machine.pizzeria.TILE_SIZE + Vec3(machine.pizzeria.TILE_SIZE/2)
		#	machine.delete_object_range(object_node.index, end_cell, field)
		machine.gizmo_box.visible = false

# Materindex.list_all.materials[machine.current_item].is_wall_mat == false


func InputUpdate(event, machine):
	machine.gizmo_box.visible = true
	if !is_on_object:
		if is_floor and not removing_wall:
			if end_cell == null:
				machine.gizmo_box.global_position = Vector3i(projected_cell.x, machine.current_floor_idx * machine.pizzeria.WALL_HEIGHT, projected_cell.y)
				machine.gizmo_box.global_position *= Vector3(machine.pizzeria.TILE_SIZE, 1, machine.pizzeria.TILE_SIZE)
				machine.gizmo_box.global_position += Vector3(machine.pizzeria.TILE_SIZE/2, 0, machine.pizzeria.TILE_SIZE/2)
				machine.gizmo_box.size = Vector3(machine.pizzeria.TILE_SIZE, machine.pizzeria.FLOOR_THICK, machine.pizzeria.TILE_SIZE)
			else:
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
			if end_wall == null:
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
				var start_corner := Vector2i(
					min(start_wall.x, projected_wall.x),
					max(start_wall.y, projected_wall.y))
				var end_corner := Vector2i(
					max(start_wall.x, projected_wall.x),
					min(start_wall.y, projected_wall.y))
					
				machine.gizmo_box.size = Vector3(
					abs(end_corner.x - start_corner.x),
					machine.pizzeria.WALL_HEIGHT,
					abs(start_corner.y - end_corner.y))
				
				if orientation == false:
					machine.gizmo_box.size += Vector3(1, 0, 0)
				elif orientation == true:
					machine.gizmo_box.size += Vector3(0, 0, 1)
				
				machine.gizmo_box.size *= Vector3(
					machine.pizzeria.TILE_SIZE,
					1,
					machine.pizzeria.TILE_SIZE)
					
				machine.gizmo_box.global_position = Vector3(
					start_corner.x * machine.pizzeria.TILE_SIZE + machine.gizmo_box.size.x/2.0,
					machine.current_floor_idx * machine.pizzeria.WALL_HEIGHT + machine.pizzeria.WALL_HEIGHT/2.0,
					end_corner.y * machine.pizzeria.TILE_SIZE + machine.gizmo_box.size.z/2.0
				)



func Vec3(n):
	return Vector3(n,0,n)

func Enter(machine : DayshiftManager):
	start_cell = Vector2i.ZERO
	end_cell = Vector2i.ZERO
	machine.gizmo_level = machine.GIZMO_LEVELS.NEGATIVE
	#add_child(debug_point)

func Exit(machine : DayshiftManager):
	start_cell = Vector2i.ZERO
	end_cell = Vector2i.ZERO
	machine.gizmo_level = machine.GIZMO_LEVELS.NEUTRAL
