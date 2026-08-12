extends StateMachine
class_name DayshiftManager

@export var pizzeria: MasterPizzeria
# enum states {PLACING, SELECT, ROOM, WALL}

## Variable storing the cell the mouse is on.
var current_cell : Vector2i = Vector2i(0, 0)

## Floor currently being edited as an index from pizzeria's floors array
var current_floor_idx = 0 

var gizmo_box := CSGBox3D.new()


@onready var camera = get_viewport()

var action_history : Array[ActionStackActionGroup] = []
var max_remembered_actions : int = 16

enum fields {GROUND, WALL, OBJECT}

var mouse_coordinates
var collider
var hit_pos
var hit_normal

# NOTE: cell index coordinates can be roughly defined as m/TS, where TS is
# the tile size, so in order to use them for positioning, you must ALWAYS
# multiply them by the tile size to get meters back


# TODO: implement redo

func new_actiongroup():
	var newgroup = ActionStackActionGroup.new()
	action_history.push_front(newgroup)
	if len(action_history) >= max_remembered_actions:
		action_history.pop_back()
func _ready_extra():
	gizmo_box.size = Vector3(pizzeria.TILE_SIZE, pizzeria.FLOOR_THICK, pizzeria.TILE_SIZE)
	gizmo_box.material = load("uid://dcaedodw0xujq")
	self.add_child(gizmo_box)

func _input(event):
	# getting absolute / world space coords
	# don't ask me how it works it's old code from back when this was a mall game
	var mouse_pos = camera.get_mouse_position()
	var origin = camera.get_camera_3d().project_ray_origin(mouse_pos)
	var dir = camera.get_camera_3d().project_ray_normal(mouse_pos)
	var plane_y = float(current_floor_idx * pizzeria.WALL_HEIGHT)
	mouse_coordinates = Plane(Vector3(0, 1, 0), plane_y).intersects_ray(origin, dir)
	
	var query = PhysicsRayQueryParameters3D.create(origin, origin + dir * 1000)
	var space_state = camera.get_camera_3d().get_world_3d().direct_space_state
	var result = space_state.intersect_ray(query)
	
	if result:
		collider = result.collider
		hit_pos = result.position
		hit_normal = result.normal
	
		if collider.is_in_group("office_devices"):
			return
	
	
	# converting to tile space
	if mouse_coordinates:
		current_cell = Vector2i(floori(float(mouse_coordinates.x) / pizzeria.TILE_SIZE), floori(float(mouse_coordinates.z) / pizzeria.TILE_SIZE))
	
	
	# state machine code
	if current_state:
		current_state.InputUpdate(event, self)


#region undo system actions

func place_floortile_single(idx : Vector2i):
	new_actiongroup()
	var template = pizzeria_room.new()
	add_cell(Vector3i(idx.x, idx.y, 0), template, fields.GROUND, current_floor_idx)
	pizzeria.render_chunk(pizzeria.to_chunk(idx), pizzeria.floors[current_floor_idx], pizzeria.WALL_HEIGHT * current_floor_idx)

func place_floortile_range(idx_begin : Vector2i, idx_end : Vector2i):
	new_actiongroup()
	var template = pizzeria_room.new()
	var x_step = 1
	var y_step = 1
	
	# in case it has to step backwards in order to progress to the desired tile
	if idx_begin.x > idx_end.x:
		x_step = -1
	if idx_begin.y > idx_end.y:
		y_step = -1
	
	var chunks = []
	# going through the square
	# adding x and y step because ranges are exclusive
	for x in range(idx_begin.x, idx_end.x + x_step, x_step):
		for y in range(idx_begin.y, idx_end.y + y_step, y_step):
			add_cell(Vector3i(x, y, 0), template, fields.GROUND, current_floor_idx)
			if not chunks.has(pizzeria.to_chunk(Vector2i(x, y))):
				chunks.append(pizzeria.to_chunk(Vector2i(x, y)))
			

	# this will tally up all chunks that should be re-rendered
	for chunk in chunks:
		pizzeria.render_chunk(chunk, pizzeria.floors[current_floor_idx], current_floor_idx * pizzeria.WALL_HEIGHT)

func place_walltile_range(idx_begin, idx_end, direction):
	new_actiongroup()
	var template = pizzeria_wall.new()
	template.base_set_type(pizzeria_wall.WALL_TYPES.FLAT)
	var step = 1
	
	var chunks = []
	
	# if it's a horizontal wall
	if direction == false:
		# in case it has to step backwards in order to progress to the desired tile
		var given_range = range(idx_begin.x, idx_end.x+step, step)
		if idx_begin.x > idx_end.x:
			step = -1
			given_range = range(idx_begin.x + step, idx_end.x, step)
			
		for i in given_range:
			add_cell(Vector3i(i, idx_begin.y, 0), template, fields.WALL, current_floor_idx)
			if not chunks.has(pizzeria.to_chunk(Vector2i(i, idx_begin.y))):
				chunks.append(pizzeria.to_chunk(Vector2i(i, idx_begin.y)))
	
	# if it's a vertical wall
	else:
		# in case it has to step backwards in order to progress to the desired tile
		var given_range = range(idx_begin.y, idx_end.y+step, step)
		if idx_begin.y > idx_end.y:
			step = -1
			given_range = range(idx_begin.y + step, idx_end.y, step)
		
		for i in given_range:
			add_cell(Vector3i(idx_begin.x, i, 1), template, fields.WALL, current_floor_idx)
			
			if not chunks.has(pizzeria.to_chunk(Vector2i(idx_begin.x, i))):
				chunks.append(pizzeria.to_chunk(Vector2i(idx_begin.x, i)))
	
	for chunk in chunks:
		pizzeria.render_chunk(chunk, pizzeria.floors[current_floor_idx], current_floor_idx * pizzeria.WALL_HEIGHT)

func delete_floortile_range(idx_begin : Vector2i, idx_end : Vector2i):
	new_actiongroup()
	var x_step = 1
	var y_step = 1
	
	# in case it has to step backwards in order to progress to the desired tile
	if idx_begin.x > idx_end.x:
		x_step = -1
	if idx_begin.y > idx_end.y:
		y_step = -1
	
	var chunks = []
	# going through the square
	# adding x and y step because ranges are exclusive
	for x in range(idx_begin.x, idx_end.x + x_step, x_step):
		for y in range(idx_begin.y, idx_end.y + y_step, y_step):
			
			if pizzeria.floors[current_floor_idx].groundtiles.has(Vector2i(x, y)):
				remove_cell(Vector3i(x, y, 0), fields.GROUND, current_floor_idx)
			if pizzeria.floors[current_floor_idx].walls.has(Vector3i(x, y, 0)):
				remove_cell(Vector3i(x, y, 0), fields.WALL, current_floor_idx)
			if pizzeria.floors[current_floor_idx].walls.has(Vector3i(x, y, 1)):
				remove_cell(Vector3i(x, y, 1), fields.WALL, current_floor_idx)
			
			if not chunks.has(pizzeria.to_chunk(Vector2i(x, y))):
				chunks.append(pizzeria.to_chunk(Vector2i(x, y)))
			
	
	# this will tally up all chunks that should be re-rendered
	for chunk in chunks:
		pizzeria.render_chunk(chunk, pizzeria.floors[current_floor_idx], current_floor_idx * pizzeria.WALL_HEIGHT)


func delete_wall_range(idx_begin : Vector2i, idx_end : Vector2i):
	new_actiongroup()
	var x_step = 1
	var y_step = 1
	
	# in case it has to step backwards in order to progress to the desired tile
	if idx_begin.x > idx_end.x:
		x_step = -1
	if idx_begin.y > idx_end.y:
		y_step = -1
	
	var chunks = []
	# going through the square
	# adding x and y step because ranges are exclusive
	for x in range(idx_begin.x, idx_end.x + x_step, x_step):
		for y in range(idx_begin.y, idx_end.y + y_step, y_step):
			remove_cell(Vector3i(x, y, 0), fields.WALL, current_floor_idx)
			remove_cell(Vector3i(x, y, 1), fields.WALL, current_floor_idx)

			if not chunks.has(pizzeria.to_chunk(Vector2i(x, y))):
				chunks.append(pizzeria.to_chunk(Vector2i(x, y)))
	
	
	# this will tally up all chunks that should be re-rendered
	for chunk in chunks:
		pizzeria.render_chunk(chunk, pizzeria.floors[current_floor_idx], current_floor_idx * pizzeria.WALL_HEIGHT)

#endregion

# The way the undo system works is that every modification can be boiled down
# to: it either adds new information, or deletes it. Replacing follows the same
# behavior as deleting for these purposes.
#
# Everything that ever involves a floor's data structure MUST be done through
# the helper functions so it can be undone.
#
# The data structure is as follows:
# 	
# 	action_history holds groups of actions
# 	(this is so you can undo compound actions at once, such the range functions)
# 				|
# 				V
# 		these groups can hold one or more actions
# 				|
# 				V
# 		actions store:
# 			index - the index of the cell that changed
# 			field - the field (from pizzeria_floor data structure) that was changed
# 			floor_index - the index of the floor that was modified
# 			old_data - the data of the cell that used to be in the index
#
# the way it works,
# 	if the cell didn't have anything before and it just added it (aka if old_data null)
# 		it will remove it cleanly, without recording it (for now)
# 	if it did (whether it's because it was removed or because it was replaced)
# 		it will go to that cell and restore what was before
#		sometimes add_cell can do this (for now) when it overlaps with existing
#		ground tiles, so it is treated the same as removing. This is also
#		convenient when dealing with cases where you're reconfiguring
#		something, because if we treat it as rewriting tile data on the
#		object field, it allows us to restore the previous configuration
#
# each time you take an action, it has to create a new group at the top to
# contain it (hence new_actiongroup())
# if anything else is unclear, you can ask me


func undo():
	if len(action_history) > 0:
		var chunks = {}
		for action : ActionStackAction in action_history[0].actions:
			# if we don't have the floor index or the chunk number, we make it
			if not chunks.has(action.floor_idx):
				chunks.get_or_add(action.floor_idx, [])
			if not chunks.get_or_add(action.floor_idx).has(pizzeria.to_chunk(Vector2i(action.idx.x, action.idx.y))):
					chunks.get_or_add(action.floor_idx).append(pizzeria.to_chunk(Vector2i(action.idx.x, action.idx.y)))
			
			if action.old_data == null:
				remove_cell(action.idx, action.field, action.floor_idx, true)
			else:
				add_cell(action.idx, action.old_data, action.field, action.floor_idx, true)
		action_history.pop_front()
		
		for floor_level in chunks.keys():
			for chunk in chunks[floor_level]:
				pizzeria.render_chunk(chunk, pizzeria.floors[floor_level], floor_level * pizzeria.WALL_HEIGHT)

func add_cell(idx : Vector3i, data, field : fields, floor_idx : int=0, is_undo : bool = false):
	var is_overriding = false
	if data == null:
		return
	var new_action = ActionStackAction.new()
	new_action.field = field
	new_action.idx = idx
	new_action.floor_idx = floor_idx
	new_action.new_data = data
	match field:
		fields.GROUND:
			if pizzeria.floors[floor_idx].groundtiles.has(Vector2i(idx.x, idx.y)):
				is_overriding = true
				new_action.old_data = pizzeria.floors[floor_idx].groundtiles[Vector2i(idx.x, idx.y)]
			pizzeria.floors[floor_idx].groundtiles[Vector2i(idx.x, idx.y)] = data
		fields.WALL:
			if pizzeria.floors[floor_idx].walls.has(idx):
				is_overriding = true
				new_action.old_data = pizzeria.floors[floor_idx].walls[idx]
			pizzeria.floors[floor_idx].walls[idx] = data
		fields.OBJECT:
			#TODO: Implement along with object system
			pass
	if !is_undo:
		action_history[0].actions.append(new_action)

func remove_cell(idx : Vector3i, field : fields, floor_idx : int=0, is_undo : bool = false):
	var new_action = ActionStackAction.new()
	new_action.field = field
	new_action.idx = idx
	new_action.floor_idx = floor_idx
	match field:
		fields.GROUND:
			if pizzeria.floors[floor_idx].groundtiles.has(Vector2i(idx.x, idx.y)):
				new_action.old_data = pizzeria.floors[floor_idx].groundtiles[Vector2i(idx.x, idx.y)]
			pizzeria.floors[floor_idx].groundtiles.erase(Vector2i(idx.x, idx.y))
		fields.WALL:
			if pizzeria.floors[floor_idx].walls.has(idx):
				new_action.old_data = pizzeria.floors[floor_idx].walls[idx]
			pizzeria.floors[floor_idx].walls.erase(idx)
		fields.OBJECT:
			#TODO: Implement along with object system
			pass
		
	if !is_undo:
		action_history[0].actions.append(new_action)

func _process(delta: float) -> void:
	if current_state:
		current_state.Update(delta, self)
	
	if Input.is_action_just_pressed(&"undo"):
		undo()
