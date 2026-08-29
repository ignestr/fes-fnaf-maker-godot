extends StateMachineState
class_name animatronic_place_state



var projected_cell

var is_floor = true
# horizontal if false, vertical if true
var orientation = false

var is_on_anchor = false
var is_on_object = false

var anchor_index
var anchor_parent_index
var anchor_field

var obtained_cell
var obtained_quadrant

var gizmo_obj : MeshInstance3D
var collision_detect : Area3D

var is_invalid = false

var scene
var collision_displacement : Vector3

#var debug_point : CSGSphere3D

# TODO: make this logic be skippable if hovering over an object (as we can
# just check for those. Wait until objects are implemented)

func encode_wall_coord(flat_idx : Vector2i, anchor : int, vertical : bool, front : bool):
	var w = int(vertical) | int(front) << 1
	return Vector4i(flat_idx.x, flat_idx.y, anchor, w)

func Update(delta, machine : DayshiftManager = null):
	if machine:
		# default to this
		projected_cell = machine.current_cell
		
		# The way this works is if the normal of the object we hit
		# is up, we can know whether it's a floor or not
		if machine.hit_normal:
			if machine.collider:
				if machine.collider.is_in_group(&"editor_subobj_anchor"):
					is_on_anchor = true
					anchor_index = machine.collider.index
					anchor_parent_index = machine.collider.get_parent().index
					anchor_field = machine.collider.get_parent().field
				else:
					is_on_anchor = false
			# if its vector is upward, it's a floor and we need no extra logic
			obtained_cell = Vector2i(
				floori(float(machine.hit_pos.x) / machine.pizzeria.TILE_SIZE),
				floori(float(machine.hit_pos.z) / machine.pizzeria.TILE_SIZE))
			
			var mouse_position = Vector2(machine.hit_pos.x, machine.hit_pos.z)
			var cell_center = Vector2(obtained_cell) * machine.pizzeria.TILE_SIZE + Vector2(machine.pizzeria.TILE_SIZE/2, machine.pizzeria.TILE_SIZE/2)
			var dist = (mouse_position - cell_center) /2
			
			obtained_quadrant = Vector2i(
			roundi(dist.x),
			roundi(dist.y)
			)
			
			obtained_quadrant = MasterPizzeria.tile_quadrant_lut.find_key(obtained_quadrant)
			
			if machine.hit_normal.y > 0.9:
				is_floor = true
				projected_cell = machine.current_cell
			else:
				# if it's not, it's not a floor, defaulting to horizontal
				is_floor = false
	# if it's in the air, invalid
	if !is_floor:
		is_invalid = true
	else:
		is_invalid = false
	
	if is_floor:
		if !machine.pizzeria.floors[machine.current_floor_idx].groundtiles.has(projected_cell):
			is_invalid = true
		elif !is_invalid:
			is_invalid = false
		
		
		if collision_detect.has_overlapping_bodies():
			is_invalid = true
			print("this is why")
		# in case it's invalid for another reason
		elif !is_invalid:
			is_invalid = false
			#debug_point.global_position = collision_detect.global_position
	
	# Wall objects don't get checked
	# "because it allows for more freedom"
	
	# After a value is decided, set the gizmo level
	if is_invalid:
		machine.gizmo_level = machine.GIZMO_LEVELS.NEGATIVE
	else:
		machine.gizmo_level = machine.GIZMO_LEVELS.POSITIVE
	
	
func InputUpdate(event, machine : DayshiftManager):
	# if we're aiming at the ground
	gizmo_obj.visible = true
	if is_floor:
		gizmo_obj.global_position = Vector3(projected_cell.x, machine.current_floor_idx * machine.pizzeria.WALL_HEIGHT, projected_cell.y)
		gizmo_obj.global_position *= Vector3(machine.pizzeria.TILE_SIZE, 1, machine.pizzeria.TILE_SIZE)
		gizmo_obj.global_position += Vector3(machine.pizzeria.TILE_SIZE/2, 0, machine.pizzeria.TILE_SIZE/2)
		if obtained_quadrant:
			gizmo_obj.global_position += (Vector3(
			MasterPizzeria.tile_quadrant_lut[obtained_quadrant].x,
			0,
			MasterPizzeria.tile_quadrant_lut[obtained_quadrant].y
			)) * machine.pizzeria.TILE_SIZE/2
		collision_detect.global_position = gizmo_obj.global_position
		# so the floor won't trigger it
		collision_detect.global_position.y += machine.pizzeria.FLOOR_THICK/2 + 0.1
		collision_detect.global_position += collision_displacement
		
			# if we're placing something on the roof by aiming below it
	
	if Input.is_action_just_pressed("lclick"):
		if get_viewport().gui_get_hovered_control():
			return
		
		#TODO: add ERROR sfx
		if is_invalid:
			return
		var new_animatronic = pizzeria_animatronic.new()
		new_animatronic.id = machine.current_item
		#new_animatronic.ai_resource TBD
		if !is_on_anchor:
			print("once")
			machine.place_object(Vector3i(projected_cell.x, projected_cell.y, obtained_quadrant), new_animatronic, machine.fields.ANIMATRONICS)
		else:
			machine.place_object_anchor(anchor_parent_index, anchor_index, new_animatronic, machine.fields.ANIMATRONICS)
		
		if !Input.is_action_pressed(&"shift"):
			machine.state(machine.default_state)

func Enter(machine : DayshiftManager):
	machine.gizmo_level = machine.GIZMO_LEVELS.POSITIVE
	machine.gizmo_box.visible = false
	gizmo_obj = MeshInstance3D.new()
	if !machine.pizzeria.tronicman.tronics.has(machine.current_item):
		await machine.pizzeria.tronicman.load_new(machine.current_item)
		scene = machine.pizzeria.tronicman.tronics[machine.current_item].instantiate()
	else:
		scene = machine.pizzeria.tronicman.tronics[machine.current_item].instantiate()
	if scene.use_point or scene.gizmo_mesh == null:
		gizmo_obj.mesh = SphereMesh.new()
	else:
		gizmo_obj.mesh = scene.gizmo_mesh
	
	
	gizmo_obj.scale = Vector3(scene.scale_factor, scene.scale_factor ,scene.scale_factor)
	gizmo_obj.rotation = Vector3(deg_to_rad(scene.custom_rotation_degrees.x), deg_to_rad(scene.custom_rotation_degrees.y), deg_to_rad(scene.custom_rotation_degrees.z))
	gizmo_obj.material_overlay = machine.gizmo_box.material
	gizmo_obj.material_overlay.albedo = machine.gizmo_positive_color
	gizmo_obj.visible = false
	
	if scene.collision_shape:
		collision_detect = Area3D.new()
		var shape = CollisionShape3D.new()
		shape.shape = scene.collision_shape.shape
		shape.scale = Vector3(scene.scale_factor, scene.scale_factor, scene.scale_factor)
		collision_detect.rotation = Vector3(deg_to_rad(scene.custom_rotation_degrees.x), deg_to_rad(scene.custom_rotation_degrees.y), deg_to_rad(scene.custom_rotation_degrees.z))
		collision_displacement = scene.collision_displacement
		collision_detect.position += collision_displacement
		collision_detect.add_child(shape)
		
		machine.add_child(collision_detect)
	else:
		print(machine.current_item, " has no collision shape defined.")
	
	add_child(gizmo_obj)
	
	#debug_point = CSGSphere3D.new()
	#machine.add_child(debug_point)



func Exit(machine : DayshiftManager):
	machine.gizmo_level = machine.GIZMO_LEVELS.NEUTRAL
	machine.gizmo_box.visible = true
	gizmo_obj.queue_free()
