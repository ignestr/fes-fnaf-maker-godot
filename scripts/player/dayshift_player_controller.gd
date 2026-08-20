extends CharacterBody3D

const SPEED = 7.5
const JUMP_VELOCITY = 4.5

@onready var dayshift_manager : DayshiftManager = $"../DayshiftManager"
@onready var categories_container: VBoxContainer = $Control/MarginContainer/Catalog/MarginContainer/HBoxContainer/VBoxContainer/Panel2/MarginContainer/categories/VBoxContainer
@onready var catalog_grid: GridContainer = $Control/MarginContainer/Catalog/MarginContainer/HBoxContainer/MarginContainer/Panel/MarginContainer/ScrollContainer/GridContainer

var CATEGORY_BUTTON = load("uid://cu2l73mlss5c3")
var CATALOG_ENTRY_BUTTON = load("uid://b6wl33yni3utc")


func _physics_process(delta: float) -> void:
	
	var input_dir := Input.get_vector("left", "right", "fwrd", "back")
	var direction := (transform.basis *  Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	move_and_slide()


func _on_floor_button_pressed() -> void:
	dayshift_manager.state(dayshift_manager.states[&"ground_place_state"])


func _on_wall_button_pressed() -> void:
	dayshift_manager.state(dayshift_manager.states[&"wall_place_state"])


func _on_room_button_pressed() -> void:
	dayshift_manager.state(dayshift_manager.states[&"room_place_state"])


func _on_select_button_pressed() -> void:
	pass # Replace with function body.


func _on_delete_button_pressed() -> void:
	dayshift_manager.state(dayshift_manager.states[&"delete_state"])


func on_catalog_material() -> void:
	for child in categories_container.get_children():
		child.queue_free()
	
	for category in Materindex.list_all.categories:
		var new_button = CATEGORY_BUTTON.instantiate()
		new_button.player = self
		new_button.category_name = category
		new_button.icon_texture = Materindex.list_all.categories[category].icon
		categories_container.add_child(new_button)

func catalog_load_category_material(id : StringName):
	for child in catalog_grid.get_children():
		child.queue_free()
	
	for item in Materindex.list_all.categories[id].members:
		var new_button = CATALOG_ENTRY_BUTTON.instantiate()
		new_button.id = item
		new_button.player = self
		new_button.natural_name = Materindex.list_all.materials[item].natural_name
		if !Materindex.list_all.materials.has(item):
			continue
		var material = load(Materindex.list_all.materials[item].material)
		if material:
			new_button.icon_texture = material.albedo_texture
		catalog_grid.add_child(new_button)

func start_placing_material(id : StringName):
	dayshift_manager.current_item = id
