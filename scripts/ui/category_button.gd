extends Button

var player 
var category_name : StringName
var icon_texture : Texture2D
@onready var texture_rect: TextureRect = $MarginContainer/TextureRect


func _input(event: InputEvent) -> void:
	if button_pressed:
		player.catalog_load_category_material(category_name)

func _ready() -> void:
	if icon_texture:
		texture_rect.texture = icon_texture
	text = category_name
