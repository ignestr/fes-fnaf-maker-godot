extends Node3D
class_name DayshiftBuildSystem


@onready var mall: master_pizzeria = $"../../../World/mall"

@onready var camera: Camera3D = $"../Camera3D"
enum states {ADD, REMOVE, SELECT, ROOM}
var curState = states.ADD
var selecteObject = 0
var selectedEstablishment = 0
var selectedDecor = 0
var selected_rooms = []
var curFloor = 0
var cellHoveredOnPos : Vector3i = Vector3(0, 0, 0)
var gizmoMeshInstance


#TODO refactor this bad boy you slave
# 29/3/2026 no

func _input(event):
	var mouse_pos = get_viewport().get_mouse_position()
	var origin = camera.project_ray_origin(mouse_pos)
	var dir = camera.project_ray_normal(mouse_pos)
	var plane_y = curFloor * 2
	var point = Plane(Vector3(0, 1, 0), plane_y).intersects_ray(origin, dir)
	if point:
		cellHoveredOnPos = Vector3i( roundi(point.x), curFloor, roundi(point.z) )
	
	#TODO, add states and other object placement
	#if curState == states.ADD:
	#	if cellHoveredOnPos and selectedBaseObj:
	#			if Input.is_action_just_released("lclick"):
	#				mall.add_world_tile(cellHoveredOnPos, selectedBaseObj)
	#				print("I went to add town and everybody knew you")
					
					
	#elif curState == states.REMOVE:
	#	if cellHoveredOnPos:
	#		if Input.is_action_just_released("lclick"):
	#			mall.remove_world_tile(cellHoveredOnPos)
	#			print("bro is removeState maxxing")
	#			
	#elif curState == states.SELECT:
	#	if Input.is_action_pressed("lclick") and Input.is_action_pressed("shift"):
	#		if cellHoveredOnPos:
	#			if selectedCells.has(cellHoveredOnPos):
	#				selectedCells.erase(cellHoveredOnPos)
	#			else:
	#				selectedCells.append(cellHoveredOnPos)
	#	elif Input.is_action_just_pressed("lclick"):
	#		if cellHoveredOnPos:
	#			if selectedCells.has(cellHoveredOnPos):
	#				selectedCells.erase(cellHoveredOnPos)
	#			else:
	#				selectedCells.append(cellHoveredOnPos)
	#		print("bro is selecting")
