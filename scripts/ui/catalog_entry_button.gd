extends Button

var player 
var id : StringName
var natural_name : String
var icon_texture : Texture2D
@onready var texture_rect: TextureRect = $MarginContainer/TextureRect

# TODO: add popup menus to show natural name and search bar for catalog - FNAF 2 Update

func _input(event: InputEvent) -> void:
	if button_pressed:
		player.dayshift_manager.current_item = id
		player.dayshift_manager.state(player.dayshift_manager.states[&"set_material_state"])
		

func _ready() -> void:
	if icon_texture:
		texture_rect.texture = icon_texture
	#label.text = natural_name
