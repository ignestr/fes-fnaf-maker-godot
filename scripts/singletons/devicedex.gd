extends Node

var defaults := {
	pizzeria_wall.WALL_FLAGS.HAS_DOOR : {
		pizzeria_wall.WALL_TYPES.DOOR: &"fnaf1_door_1",
		pizzeria_wall.WALL_TYPES.FLOORVENT: &"fnaf2_fvent_door_1", 
		pizzeria_wall.WALL_TYPES.HALL: &"fnaf2_hall_door_1", 
		pizzeria_wall.WALL_TYPES.ROOFVENT: &"ucn_rvent_door_2",
		pizzeria_wall.WALL_TYPES.WALLVENT: &"fnaf6_wvent_door_1"
		}, 
	pizzeria_wall.WALL_FLAGS.HAS_GLASS: {
		pizzeria_wall.WALL_TYPES.DOOR: &"fnaf1_windoor_doorglass_1",
		pizzeria_wall.WALL_TYPES.HALL: &"fnaf3_window_hallglass_1", 
		pizzeria_wall.WALL_TYPES.WALLVENT: &"fnafx_replace_1"  # TODO: make this
		}, 
	-1: {
		pizzeria_wall.WALL_TYPES.DOOR: &"fnaf1_door_1_empty",
		pizzeria_wall.WALL_TYPES.FLOORVENT: &"fnaf2_fvent_1_empty", 
		pizzeria_wall.WALL_TYPES.HALL: &"fnaf2_hall_1_empty", 
		pizzeria_wall.WALL_TYPES.ROOFVENT: &"ucn_rvent_2_empty",
		pizzeria_wall.WALL_TYPES.WALLVENT: &"fnaf6_wvent_1_empty" 
		}
	}


@export var list_all : DeviceIndexResource = load("uid://yeo2nmm16si0")
