extends CharacterBody3D

const SPEED = 7.5
const JUMP_VELOCITY = 4.5



@onready var dayshift_manager : DayshiftManager = $"../DayshiftManager"
@onready var categories_container: VBoxContainer = $Control/MarginContainer/Catalog/MarginContainer/HBoxContainer/VBoxContainer/Panel2/MarginContainer/categories/VBoxContainer
@onready var catalog_grid: GridContainer = $Control/MarginContainer/Catalog/MarginContainer/HBoxContainer/MarginContainer/Panel/MarginContainer/ScrollContainer/GridContainer
@onready var properties_container: VBoxContainer = $Control/MarginContainer/FoldableContainer/Context_Menu/MarginContainer2/ScrollContainer/VBoxContainer

var CATEGORY_BUTTON = load("uid://cu2l73mlss5c3")
var CATALOG_ENTRY_BUTTON = load("uid://b6wl33yni3utc")

var PROPERTYWIDGET_BOOL = load("uid://cmyp0ob31rslu")
var PROPERTYWIDGET_COLORPICKER = load("uid://bymdtxrfau1ws")
var PROPERTYWIDGET_FLOAT = load("uid://bpy7lirju57td")
const PROPERTYWIDGET_VECTOR_2 = preload("uid://c3jha1tkmfem5")


#@onready var deubg_label: Label = $Control/MarginContainer/Context_Menu/MarginContainer/VBoxContainer/Panel/MarginContainer/ScrollContainer/VBoxContainer/Label

var resource_view


func _physics_process(delta: float) -> void:
	if get_viewport().gui_get_focus_owner():
		if !get_viewport().gui_get_hovered_control() == null:
			return
	var input_dir := Input.get_vector("left", "right", "fwrd", "back")
	var direction := (transform.basis *  Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	move_and_slide()

func _ready() -> void:
	dayshift_manager.has_selected.connect(object_selected)


func _on_floor_button_pressed() -> void:
	dayshift_manager.state(dayshift_manager.states[&"ground_place_state"])


func _on_wall_button_pressed() -> void:
	dayshift_manager.state(dayshift_manager.states[&"wall_place_state"])


func _on_room_button_pressed() -> void:
	dayshift_manager.state(dayshift_manager.states[&"room_place_state"])


func _on_select_button_pressed() -> void:
	dayshift_manager.state(dayshift_manager.states[&"select_state"])


func _on_delete_button_pressed() -> void:
	dayshift_manager.state(dayshift_manager.states[&"delete_state"])

func object_selected():
	var object : Object
	var properties = {}
	if dayshift_manager.selected_object.get_script():
		var list = dayshift_manager.selected_object.get_property_list()
		list.reverse()
		for i in list:
			if i["name"].contains("property_"):
				if !dayshift_manager.selected_object.show_transform_properties:
					if i["name"] == "property_offset" or i["name"] == "property_rotation_offset":
						continue
				properties[i["name"]] = i["type"]
		
		for child in properties_container.get_children():
			child.queue_free()
		
		for i in properties:
			var new_widget
			match properties[i]:
				TYPE_COLOR:
					new_widget = PROPERTYWIDGET_COLORPICKER.instantiate()
					new_widget.player = self
					new_widget.p_name = i
					new_widget.value = dayshift_manager.selected_object.get(i)
					properties_container.add_child(new_widget)
				TYPE_FLOAT:
					new_widget = PROPERTYWIDGET_FLOAT.instantiate()
					new_widget.player = self
					new_widget.p_name = i
					new_widget.value = dayshift_manager.selected_object.get(i)
					properties_container.add_child(new_widget)
				TYPE_BOOL:
					new_widget = PROPERTYWIDGET_BOOL.instantiate()
					new_widget.player = self
					new_widget.p_name = i
					new_widget.value = dayshift_manager.selected_object.get(i)
					properties_container.add_child(new_widget)
				TYPE_VECTOR2:
					new_widget = PROPERTYWIDGET_VECTOR_2.instantiate()
					new_widget.player = self
					new_widget.p_name = i
					new_widget.value = dayshift_manager.selected_object.get(i)
					properties_container.add_child(new_widget)

func set_property(p_name, val):
	var object = dayshift_manager.selected_object
	if object:
		if object.is_in_group(&"objects"):
			object.set(p_name, val)
			var old_object
			var field = object.field
			match field:
				dayshift_manager.fields.OBJECT_GROUND:
					old_object = dayshift_manager.pizzeria.floors[dayshift_manager.current_floor_idx].objects_ground[object.index].clone()
				dayshift_manager.fields.OBJECT_WALL:
					old_object = dayshift_manager.pizzeria.floors[dayshift_manager.current_floor_idx].objects_wall[object.index].clone()
				dayshift_manager.fields.OBJECT_ROOF:
					old_object = dayshift_manager.pizzeria.floors[dayshift_manager.current_floor_idx].objects_roof[object.index].clone()
				dayshift_manager.fields.ANIMATRONICS:
					old_object = dayshift_manager.pizzeria.floors[dayshift_manager.current_floor_idx].animatronics[object.index].clone()
			old_object.properties[p_name] = val
			if dayshift_manager.selected_object.is_on_anchor:
				dayshift_manager.place_object_anchor(object.index, object.anchor_number, field, old_object, false)
			else:
				dayshift_manager.place_object(object.index, old_object, field, false)

#region catalog
func on_catalog_material() -> void:
	for child in categories_container.get_children():
		child.queue_free()
	
	for category in Materindex.list_all.categories:
		var new_button = CATEGORY_BUTTON.instantiate()
		new_button.player = self
		new_button.category_name = category
		new_button.icon_texture = Materindex.list_all.categories[category].icon
		new_button.type = dayshift_manager.CATALOG_TYPES.MATERIAL
		categories_container.add_child(new_button)

func catalog_load_category_material(id : StringName):
	for child in catalog_grid.get_children():
		child.queue_free()
	
	for item in Materindex.list_all.categories[id].members:
		var new_button = CATALOG_ENTRY_BUTTON.instantiate()
		new_button.id = item
		new_button.player = self
		new_button.natural_name = Materindex.list_all.materials[item].natural_name
		new_button.type = dayshift_manager.CATALOG_TYPES.MATERIAL
		if !Materindex.list_all.materials.has(item):
			continue
		var material = load(Materindex.list_all.materials[item].material)
		if material:
			new_button.icon_texture = material.albedo_texture
		catalog_grid.add_child(new_button)

func catalog_load_category_furniture(id : StringName):
	for child in catalog_grid.get_children():
		child.queue_free()
	
	for item in Objex.list_all.categories_ground[id].members:
		if !Objex.list_all.objects.has(item):
			continue
		var new_button = CATALOG_ENTRY_BUTTON.instantiate()
		new_button.id = item
		new_button.player = self
		new_button.type = dayshift_manager.CATALOG_TYPES.FURNITURE
		new_button.natural_name = Objex.list_all.objects[item].natural_name

		new_button.icon_texture = Objex.list_all.objects[item].icon
		catalog_grid.add_child(new_button)

func catalog_load_category_wall(id : StringName):
	for child in catalog_grid.get_children():
		child.queue_free()
	
	for item in Objex.list_all.categories_wall[id].members:
		if !Objex.list_all.objects.has(item):
			continue
		var new_button = CATALOG_ENTRY_BUTTON.instantiate()
		new_button.id = item
		new_button.player = self
		new_button.type = dayshift_manager.CATALOG_TYPES.WALL
		new_button.natural_name = Objex.list_all.objects[item].natural_name
		new_button.icon_texture = Objex.list_all.objects[item].icon
		catalog_grid.add_child(new_button)

func catalog_load_category_roof(id : StringName):
	for child in catalog_grid.get_children():
		child.queue_free()
	
	for item in Objex.list_all.categories_roof[id].members:
		if !Objex.list_all.objects.has(item):
			continue
		var new_button = CATALOG_ENTRY_BUTTON.instantiate()
		new_button.id = item
		new_button.player = self
		new_button.type = dayshift_manager.CATALOG_TYPES.ROOF
		new_button.natural_name = Objex.list_all.objects[item].natural_name
		new_button.icon_texture = Objex.list_all.objects[item].icon
		catalog_grid.add_child(new_button)

func catalog_load_category_devices(id : StringName):
	for child in catalog_grid.get_children():
		child.queue_free()
	
	for item in CatalogDevicedex.list_all.categories[id].members:
		var new_button = CATALOG_ENTRY_BUTTON.instantiate()
		new_button.id = item.id
		new_button.player = self
	
		match item.device_type:
			item.device_types.WALL_DEVICE:
				if !Devicedex.list_all.devices.has(item.id):
					continue
				new_button.type = dayshift_manager.CATALOG_TYPES.DEVICES
				new_button.natural_name = Devicedex.list_all.devices[item.id].natural_name
				if Devicedex.list_all.devices[item.id].icon:
					new_button.icon_texture = Devicedex.list_all.devices[item.id].icon
			item.device_types.GROUND:
				if !Objex.list_all.objects.has(item.id):
					continue
				new_button.type = dayshift_manager.CATALOG_TYPES.FURNITURE
				new_button.natural_name = Objex.list_all.objects[item.id].natural_name
				if Objex.list_all.objects[item.id].icon:
					new_button.icon_texture = Objex.list_all.objects[item.id].icon
			item.device_types.WALL:
				if !Objex.list_all.objects.has(item.id):
					continue
				new_button.type = dayshift_manager.CATALOG_TYPES.WALL
				new_button.natural_name = Objex.list_all.objects[item.id].natural_name
				if Objex.list_all.objects[item.id].icon:
					new_button.icon_texture = Objex.list_all.objects[item.id].icon
			item.device_types.ROOF:
				if !Objex.list_all.objects.has(item.id):
					continue
				new_button.type = dayshift_manager.CATALOG_TYPES.ROOF
				new_button.natural_name = Objex.list_all.objects[item.id].natural_name
				if Objex.list_all.objects[item.id].icon:
					new_button.icon_texture = Objex.list_all.objects[item.id].icon
	
		catalog_grid.add_child(new_button)

func catalog_load_category_animatronics(id : StringName):
	for child in catalog_grid.get_children():
		child.queue_free()
	
	for item in Animatrindex.list_all.categories[id].members:
		if !Animatrindex.list_all.animatronics.has(item):
			continue
		var new_button = CATALOG_ENTRY_BUTTON.instantiate()
		new_button.id = item
		new_button.player = self
		new_button.type = dayshift_manager.CATALOG_TYPES.TRONICS
		new_button.natural_name = Animatrindex.list_all.animatronics[item].natural_name
		new_button.icon_texture = Animatrindex.list_all.animatronics[item].icon
		catalog_grid.add_child(new_button)


func _on_catalog_furniture() -> void:
	for child in categories_container.get_children():
		child.queue_free()
	
	for category in Objex.list_all.categories_ground:
		var new_button = CATEGORY_BUTTON.instantiate()
		new_button.player = self
		new_button.category_name = category
		new_button.icon_texture = Objex.list_all.categories_ground[category].icon
		new_button.type = dayshift_manager.CATALOG_TYPES.FURNITURE
		categories_container.add_child(new_button)


func _on_catalog_devices() -> void:
	for child in categories_container.get_children():
		child.queue_free()
	
	for category in CatalogDevicedex.list_all.categories:
		var new_button = CATEGORY_BUTTON.instantiate()
		new_button.player = self
		new_button.category_name = category
		new_button.icon_texture = CatalogDevicedex.list_all.categories[category].icon
		new_button.type = dayshift_manager.CATALOG_TYPES.DEVICES
		categories_container.add_child(new_button)


func _on_catalog_animatronics() -> void:
	for child in categories_container.get_children():
		child.queue_free()
	
	for category in Animatrindex.list_all.categories:
		var new_button = CATEGORY_BUTTON.instantiate()
		new_button.player = self
		new_button.category_name = category
		new_button.icon_texture = Animatrindex.list_all.categories[category].icon
		new_button.type = dayshift_manager.CATALOG_TYPES.TRONICS
		categories_container.add_child(new_button)


func _on_catalog_walldecor() -> void:
	for child in categories_container.get_children():
		child.queue_free()
	
	for category in Objex.list_all.categories_wall:
		var new_button = CATEGORY_BUTTON.instantiate()
		new_button.player = self
		new_button.category_name = category
		new_button.icon_texture = Objex.list_all.categories_wall[category].icon
		new_button.type = dayshift_manager.CATALOG_TYPES.WALL
		categories_container.add_child(new_button)


func _on_catalog_roof() -> void:
	for child in categories_container.get_children():
		child.queue_free()
	
	for category in Objex.list_all.categories_roof:
		var new_button = CATEGORY_BUTTON.instantiate()
		new_button.player = self
		new_button.category_name = category
		new_button.icon_texture = Objex.list_all.categories_roof[category].icon
		new_button.type = dayshift_manager.CATALOG_TYPES.ROOF
		categories_container.add_child(new_button)

#endregion


func _on_settings_pressed() -> void:
	pass # Replace with function body.


func on_export_pressed() -> void:
	pass # Replace with function body.


func on_import_pressed() -> void:
	pass # Replace with function body.
