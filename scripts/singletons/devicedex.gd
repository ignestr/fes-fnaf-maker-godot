extends Node

var defaults := {
	pizzeria_wall.WALL_FLAGS.HAS_DOOR : {
		pizzeria_wall.WALL_TYPES.DOOR: &"fnaf1_blast_door_1",
		pizzeria_wall.WALL_TYPES.FLOORVENT: &"fnaf2_fvent_door_1", 
		pizzeria_wall.WALL_TYPES.HALL: DeviceIndexDataEntry.new(), 
		pizzeria_wall.WALL_TYPES.ROOFVENT: DeviceIndexDataEntry.new(),
		pizzeria_wall.WALL_TYPES.WALLVENT: DeviceIndexDataEntry.new()
		}, 
	pizzeria_wall.WALL_FLAGS.HAS_GLASS: {
		pizzeria_wall.WALL_TYPES.DOOR: DeviceIndexDataEntry.new(),
		pizzeria_wall.WALL_TYPES.HALL: DeviceIndexDataEntry.new(), 
		pizzeria_wall.WALL_TYPES.WALLVENT: DeviceIndexDataEntry.new() 
		}, 
	-1: {
		pizzeria_wall.WALL_TYPES.DOOR: DeviceIndexDataEntry.new(),
		pizzeria_wall.WALL_TYPES.FLOORVENT: DeviceIndexDataEntry.new(), 
		pizzeria_wall.WALL_TYPES.HALL: DeviceIndexDataEntry.new(), 
		pizzeria_wall.WALL_TYPES.ROOFVENT: DeviceIndexDataEntry.new(),
		pizzeria_wall.WALL_TYPES.WALLVENT: DeviceIndexDataEntry.new() 
		}
	}


@export var list_all : DeviceIndexResource = load("uid://yeo2nmm16si0")
