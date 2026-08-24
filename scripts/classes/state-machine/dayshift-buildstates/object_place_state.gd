extends StateMachineState
class_name object_place_state


var projected_cell:= Vector2i(0, 0)

var obtained_cell := Vector2i(0, 0)
var obtained_wall_u := Vector2i(0, 0)
var obtained_wall_v := Vector2i(0, 0)


var obtained_quadrant_ground
var obtained_quadrant_wall


var is_floor = true
# horizontal if false, vertical if true
var orientation = false
var side

var gizmo_obj : MeshInstance3D
var collision_detect : Area3D

var is_invalid = false

#var debug_point : CSGSphere3D

# TODO: make this logic be skippable if hovering over an object (as we can
# just check for those. Wait until objects are implemented)

func encode_wall_coord(flat_idx : Vector2i, anchor : int, vertical : bool, front : bool):
	var w = int(vertical) | int(front) << 1
	return Vector4i(flat_idx.x, flat_idx.y, anchor, w)

func Update(delta, machine : DayshiftManager = null):
	if machine:
		# The way this works is if the normal of the object we hit
		# is up, we can know whether it's a floor or not
		if machine.hit_normal:
			# if its vector is upward, it's a floor and we need no extra logic
			obtained_cell = Vector2i(
				floori(float(machine.hit_pos.x) / machine.pizzeria.TILE_SIZE),
				floori(float(machine.hit_pos.z) / machine.pizzeria.TILE_SIZE))
			
			obtained_wall_u = Vector2i(
				floori(float(machine.hit_pos.x) / machine.pizzeria.TILE_SIZE),
				floori(float(machine.hit_pos.y) / machine.pizzeria.TILE_SIZE))
				
			obtained_wall_v = Vector2i(
				floori(float(machine.hit_pos.z) / machine.pizzeria.TILE_SIZE),
				floori(float(machine.hit_pos.y) / machine.pizzeria.TILE_SIZE))
			
			var mouse_position_ground = Vector2(machine.hit_pos.x, machine.hit_pos.z)
			var cell_center_ground = Vector2(obtained_cell) * machine.pizzeria.TILE_SIZE + Vector2(machine.pizzeria.TILE_SIZE/2, machine.pizzeria.TILE_SIZE/2)
			var dist_ground = (mouse_position_ground - cell_center_ground) /2
			
			var dist_wall = Vector2.ZERO
			var mouse_position_wall = Vector2.ZERO
			var cell_center_wall = Vector2.ZERO
			
			if orientation == false:
				mouse_position_wall = Vector2(machine.hit_pos.x, machine.hit_pos.y)
				
				cell_center_wall.x = obtained_wall_u.x * machine.pizzeria.TILE_SIZE + machine.pizzeria.TILE_SIZE/2
				cell_center_wall.y = obtained_wall_u.y * machine.pizzeria.WALL_HEIGHT + machine.pizzeria.WALL_HEIGHT/2
				dist_wall = (mouse_position_wall - cell_center_wall) /2
			else:
				mouse_position_wall = Vector2(machine.hit_pos.z, machine.hit_pos.y)
				
				cell_center_wall.x = obtained_wall_v.x * machine.pizzeria.TILE_SIZE + machine.pizzeria.TILE_SIZE/2
				cell_center_wall.y = obtained_wall_v.y * machine.pizzeria.WALL_HEIGHT + machine.pizzeria.WALL_HEIGHT/2
				dist_wall = (mouse_position_wall - cell_center_wall) /2
			
			obtained_quadrant_ground = Vector2i(
			roundi(dist_ground.x),
			roundi(dist_ground.y)
			)
			
			obtained_quadrant_wall = Vector2i(
				roundi(dist_wall.x),
				roundi(dist_wall.y)
			)
			obtained_quadrant_wall = MasterPizzeria.tile_quadrant_lut.find_key(obtained_quadrant_wall)
			if obtained_quadrant_wall == null:
				print(Vector2i(
				roundi(dist_wall.x),
				roundi(dist_wall.y)
			))
			obtained_quadrant_ground = MasterPizzeria.tile_quadrant_lut.find_key(obtained_quadrant_ground)
			
			if machine.hit_normal.y > 0.9:
				is_floor = true
				projected_cell = machine.current_cell
			else:
				# if it's not, it's not a floor, defaulting to horizontal
				is_floor = false
				orientation = false
				side = false
				
				
				match machine.hit_normal:
					Vector3(0,0,1):
						projected_cell = obtained_cell
					Vector3(0,0,-1):
						side = true
						projected_cell = obtained_cell + Vector2i(0, 1)
					Vector3(1,0,0):
						side = true
						orientation = true
						projected_cell = obtained_cell
					Vector3(-1,0,0):
						orientation = true
						projected_cell = obtained_cell + Vector2i(1, 0)
	
	# if it's in the air, invalid
	if is_floor:
		if !machine.pizzeria.floors[machine.current_floor_idx].groundtiles.has(projected_cell):
			is_invalid = true
		else:
			is_invalid = false
	
	if collision_detect.has_overlapping_bodies():
		is_invalid = true
		#debug_point.global_position = collision_detect.global_position
	
	# in case it's invalid for another reason
	elif !is_invalid:
		is_invalid = false
		#debug_point.global_position = collision_detect.global_position
	
	
	# After a value is decided, set the gizmo level
	if is_invalid:
		machine.gizmo_level = machine.GIZMO_LEVELS.NEGATIVE
	else:
		machine.gizmo_level = machine.GIZMO_LEVELS.POSITIVE

func InputUpdate(event, machine : DayshiftManager):
	# if we are aiming at the ground
	
	
	# if we're placing something in the ground
	if is_floor:
		
		if Objex.list_all.objects[machine.current_item].allowed_position == ObjectIndexDataEntry.allowed_positions.GROUND:
			gizmo_obj.global_position = Vector3(projected_cell.x, machine.current_floor_idx * machine.pizzeria.WALL_HEIGHT, projected_cell.y)
			gizmo_obj.global_position *= Vector3(machine.pizzeria.TILE_SIZE, 1, machine.pizzeria.TILE_SIZE)
			gizmo_obj.global_position += Vector3(machine.pizzeria.TILE_SIZE/2, 0, machine.pizzeria.TILE_SIZE/2)
			if obtained_quadrant_ground:
				gizmo_obj.global_position += (Vector3(
				MasterPizzeria.tile_quadrant_lut[obtained_quadrant_ground].x,
				0,
				MasterPizzeria.tile_quadrant_lut[obtained_quadrant_ground].y
				)) * machine.pizzeria.TILE_SIZE/2
			collision_detect.global_position = gizmo_obj.global_position
			# so the floor won't trigger it
			collision_detect.global_position.y += machine.pizzeria.FLOOR_THICK/2 + 0.1
		# if we're placing something on the roof by aiming below it
		else:
			# checking just in case
			if Objex.list_all.objects[machine.current_item].allowed_position == ObjectIndexDataEntry.allowed_positions.ROOF:
				gizmo_obj.global_position = Vector3(projected_cell.x, machine.current_floor_idx * machine.pizzeria.WALL_HEIGHT, projected_cell.y)
				gizmo_obj.global_position *= Vector3(machine.pizzeria.TILE_SIZE, 1, machine.pizzeria.TILE_SIZE)
				gizmo_obj.global_position += Vector3(machine.pizzeria.TILE_SIZE/2, 0, machine.pizzeria.TILE_SIZE/2)
				if obtained_quadrant_ground:
					gizmo_obj.global_position += (Vector3(
					MasterPizzeria.tile_quadrant_lut[obtained_quadrant_ground].x,
					0,
					MasterPizzeria.tile_quadrant_lut[obtained_quadrant_ground].y
					)) * machine.pizzeria.TILE_SIZE/2
	
	else:
		#TODO: Gizmo for object walls
		pass
	
	
	
	if Input.is_action_just_pressed("lclick"):
		if get_viewport().gui_get_hovered_control():
			return
		
		#TODO: add ERROR sfx
		if is_invalid:
			return
		var pos = Objex.list_all.objects[machine.current_item].allowed_position
		match pos:
			ObjectIndexDataEntry.allowed_positions.GROUND:
				if is_floor:
					var item = pizzeria_item.new()
					item.id = machine.current_item
					item.offset = Vector2.ZERO
					item.rotate_y = 0
					machine.place_object(Vector3i(projected_cell.x, projected_cell.y, int(obtained_quadrant_ground)), item, machine.fields.OBJECT_GROUND)
			ObjectIndexDataEntry.allowed_positions.WALL:
				if !is_floor:
					var item = pizzeria_item.new()
					item.id = machine.current_item
					item.offset = Vector2.ZERO
					item.rotate_y = 0
					machine.place_object(encode_wall_coord(projected_cell, obtained_quadrant_wall, orientation, side), item, machine.fields.OBJECT_WALL)
			ObjectIndexDataEntry.allowed_positions.ROOF:
				if is_floor:
					
					var item = pizzeria_item.new()
					item.id = machine.current_item
					item.offset = Vector2.ZERO
					item.rotate_y = 0
					machine.place_object(Vector3i(projected_cell.x, projected_cell.y, int(obtained_quadrant_ground)), item, machine.fields.OBJECT_ROOF)



func Enter(machine : DayshiftManager):
	machine.gizmo_level = machine.GIZMO_LEVELS.POSITIVE
	machine.gizmo_box.visible = false
	var scene
	gizmo_obj = MeshInstance3D.new()
	if !machine.pizzeria.objman.objects.has(machine.current_item):
		await machine.pizzeria.objman.load_new(machine.current_item)
		scene = machine.pizzeria.objman.objects[machine.current_item].instantiate()
	else:
		scene = machine.pizzeria.objman.objects[machine.current_item].instantiate()
	
	if scene.use_point or scene.gizmo_mesh == null:
		gizmo_obj.mesh = SphereMesh.new()
	else:
		gizmo_obj.mesh = scene.gizmo_mesh
	gizmo_obj.scale = Vector3(scene.scale_factor, scene.scale_factor ,scene.scale_factor)
	gizmo_obj.material_overlay = machine.gizmo_box.material
	gizmo_obj.material_overlay.albedo = machine.gizmo_positive_color
	
	if scene.collision_shape:
		collision_detect = Area3D.new()
		var shape = CollisionShape3D.new()
		shape.shape = scene.collision_shape.shape
		shape.scale = Vector3(scene.scale_factor, scene.scale_factor, scene.scale_factor)
		collision_detect.add_child(shape)
		
		machine.add_child(collision_detect)
	else:
		print(machine.current_item, " has no collision shape defined.")
		
	add_child(gizmo_obj)
	
	#debug_point = CSGSphere3D.new()
	#machine.add_child(debug_point)
	print("yeah?? ")



func Exit(machine : DayshiftManager):
	machine.gizmo_level = machine.GIZMO_LEVELS.NEUTRAL
	machine.gizmo_box.visible = true
	gizmo_obj.queue_free()
	collision_detect.queue_free()
