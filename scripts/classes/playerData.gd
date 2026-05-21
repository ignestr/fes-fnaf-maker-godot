extends Node
class_name aDeBugsLife

@export var grids: Panel
var floor := pizzeria_floor.new()
@onready var master: master_pizzeria = $"../World/master_pizzeria"
@onready var option_button: OptionButton = $CanvasLayer/Control/MarginContainer2/Panel/MarginContainer/VBoxContainer/OptionButton
@onready var label: Label = $CanvasLayer/Control/MarginContainer2/Panel/MarginContainer/VBoxContainer/Label

@onready var door: CheckButton = $CanvasLayer/Control/MarginContainer2/Panel/MarginContainer/VBoxContainer/door
@onready var light: CheckButton = $CanvasLayer/Control/MarginContainer2/Panel/MarginContainer/VBoxContainer/light
@onready var glas: CheckButton = $CanvasLayer/Control/MarginContainer2/Panel/MarginContainer/VBoxContainer/glas
@onready var interact: CheckButton = $CanvasLayer/Control/MarginContainer2/Panel/MarginContainer/VBoxContainer/interact



#ignore the file name

const ROOM_BUTTON  = preload("uid://o16dc8u71hwj")
const WALL_U_BUTTON = preload("uid://dnw0kqal3weno")
const WALL_V_BUTTON = preload("uid://rmhyjyxy26xt")

var mode = 0
var selected_idx:
	set(v):
		selected_idx = v
		label.text = str(selected_idx)
		if floor.walls.has(v):
			option_button.select(floor.walls[v].base_get_type())
			if floor.walls[v].base_get_flag(pizzeria_wall.WALL_FLAGS.HAS_DOOR):
				door.button_pressed = true
			else:
				door.button_pressed = false
			if floor.walls[v].base_get_flag(pizzeria_wall.WALL_FLAGS.HAS_LIGHT):
				light.button_pressed = true
			else:
				light.button_pressed = false
			if floor.walls[v].base_get_flag(pizzeria_wall.WALL_FLAGS.HAS_GLASS):
				glas.button_pressed = true
			else:
				glas.button_pressed = false
			if floor.walls[v].base_get_flag(pizzeria_wall.WALL_FLAGS.DO_INTERACT):
				interact.button_pressed = true
			else:
				interact.button_pressed = false

func _ready():
	for i in grids.get_children():
		if i.name == "rooms":
			for x in range(0,5):
				for y in range(0,5):
					var new_room = ROOM_BUTTON.instantiate()
					new_room.idx = Vector2(x,y)
					new_room.parent = self
					i.get_child(0).add_child(new_room)
		if i.name == "wall_u":
			for x in range(0,6):
				for y in range(0,5):
					var new_room = WALL_U_BUTTON.instantiate()
					new_room.idx = Vector2(x,y)
					new_room.parent = self
					i.get_child(0).add_child(new_room)

		if i.name == "wall_v":
			for x in range(0,5):
				for y in range(0,6):
					var new_room = WALL_V_BUTTON.instantiate()
					new_room.idx = Vector2(x,y)
					new_room.parent = self
					i.get_child(0).add_child(new_room)
	for i in pizzeria_wall.WALL_TYPES:
		option_button.add_item(i)


func _on_button_pressed() -> void:
	master.floors.clear()
	master.floors.append(floor)
	master.init_pizzeria()


func _on_edit_pressed() -> void:
	mode = 0


func _on_select_pressed() -> void:
	mode = 1



func _on_door_toggled(toggled_on: bool) -> void:
	if selected_idx:
		floor.walls[selected_idx].base_set_flag(pizzeria_wall.WALL_FLAGS.HAS_DOOR, toggled_on)


func _on_light_toggled(toggled_on: bool) -> void:
	if selected_idx:
		floor.walls[selected_idx].base_set_flag(pizzeria_wall.WALL_FLAGS.HAS_LIGHT, toggled_on)


func _on_glas_toggled(toggled_on: bool) -> void:
	if selected_idx:
		floor.walls[selected_idx].base_set_flag(pizzeria_wall.WALL_FLAGS.HAS_GLASS, toggled_on)


func _on_interact_toggled(toggled_on: bool) -> void:
	if selected_idx:
		floor.walls[selected_idx].base_set_flag(pizzeria_wall.WALL_FLAGS.DO_INTERACT, toggled_on)


func _on_option_button_item_selected(index: int) -> void:
	if selected_idx:
		floor.walls[selected_idx].base_set_type(index)
