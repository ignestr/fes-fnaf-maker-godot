extends StateMachineState
class_name object_place_state




var projected_cell:= Vector2i(0, 0)

var obtained_cell := Vector2i(0, 0)
var obtained_vertex := Vector2i(0, 0)

var modified_mousecoords
var current_u_wall

var obtained_quadrant

var is_floor = true
# horizontal if false, vertical if true
var orientation = false
var debug_point = CSGBox3D.new()
# TODO: make this logic be skippable if hovering over an object (as we can
# just check for those. Wait until objects are implemented)

func Update(delta, machine : DayshiftManager = null):
	
	if machine:
		# The way this works is if the normal of the object we hit
		# is up, we can know whether it's a floor or not
		if machine.hit_normal:
			# if its vector is upward, it's a floor and we need no extra logic
			obtained_cell = Vector2i(
				floori(float(machine.hit_pos.x) / machine.pizzeria.TILE_SIZE),
				floori(float(machine.hit_pos.z) / machine.pizzeria.TILE_SIZE))
			obtained_vertex = Vector2(
				roundi(float(machine.hit_pos.x) / machine.pizzeria.TILE_SIZE),
				roundi(float(machine.hit_pos.z) / machine.pizzeria.TILE_SIZE))
			
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
				orientation = false

				
				
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


	if Input.is_action_just_released("lclick"):
		if get_viewport().gui_get_hovered_control():
			return 
		if Objex.list_all.objects[machine.current_item].allowed_position == ObjectIndexDataEntry.allowed_positions.GROUND:
			if is_floor:
				var item = pizzeria_item.new()
				item.id = machine.current_item
				item.offset = Vector2.ZERO
				item.rotate_y = 0
				machine.place_object(Vector3i(projected_cell.x, projected_cell.y, int(obtained_quadrant)), item)
			else:
				pass
		machine.gizmo_box.visible = false

func InputUpdate(event, machine : DayshiftManager):
		if is_floor:
			pass
		else:
			pass


func Enter(machine : DayshiftManager):
	machine.gizmo_level = machine.GIZMO_LEVELS.POSITIVE
	machine.gizmo_box.visible = false


func Exit(machine : DayshiftManager):
	machine.gizmo_level = machine.GIZMO_LEVELS.NEUTRAL
