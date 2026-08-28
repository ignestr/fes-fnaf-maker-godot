extends Button

var player 
var id : StringName
var type : DayshiftManager.CATALOG_TYPES
var natural_name : String
var icon_texture : Texture2D
@onready var texture_rect: TextureRect = $MarginContainer/TextureRect

# TODO: add popup menus to show natural name and search bar for catalog - FNAF 2 Update

func _input(event: InputEvent) -> void:
	if button_pressed:
		player.dayshift_manager.current_item = id
		player.dayshift_manager.placing_wall_device = false
		match type:
			DayshiftManager.CATALOG_TYPES.MATERIAL:
				player.dayshift_manager.state(player.dayshift_manager.states[&"set_material_state"])
			DayshiftManager.CATALOG_TYPES.FURNITURE:
				player.dayshift_manager.state(player.dayshift_manager.states[&"object_place_state"])
			DayshiftManager.CATALOG_TYPES.WALL:
				player.dayshift_manager.state(player.dayshift_manager.states[&"object_place_state"])
			DayshiftManager.CATALOG_TYPES.ROOF:
				player.dayshift_manager.state(player.dayshift_manager.states[&"object_place_state"])
			DayshiftManager.CATALOG_TYPES.TRONICS:
				player.dayshift_manager.state(player.dayshift_manager.states[&"object_place_state"])
			DayshiftManager.CATALOG_TYPES.DEVICES:
				player.dayshift_manager.placing_wall_device = true
				player.dayshift_manager.state(player.dayshift_manager.states[&"device_place_state"])



func _ready() -> void:
	if icon_texture:
		texture_rect.texture = icon_texture
	#label.text = natural_name
