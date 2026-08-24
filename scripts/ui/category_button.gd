extends Button


var player 
var category_name : StringName
var type : DayshiftManager.CATALOG_TYPES
var icon_texture : Texture2D
@onready var texture_rect: TextureRect = $MarginContainer/TextureRect


func _input(event: InputEvent) -> void:
	if button_pressed:
		match type:
			DayshiftManager.CATALOG_TYPES.MATERIAL:
				player.catalog_load_category_material(category_name)
			DayshiftManager.CATALOG_TYPES.FURNITURE:
				player.catalog_load_category_furniture(category_name)
			DayshiftManager.CATALOG_TYPES.WALL:
				player.catalog_load_category_wall(category_name)
			DayshiftManager.CATALOG_TYPES.ROOF:
				player.catalog_load_category_roof(category_name)
			DayshiftManager.CATALOG_TYPES.TRONICS:
				player.catalog_load_category_animatronics(category_name)
			DayshiftManager.CATALOG_TYPES.DEVICES:
				player.catalog_load_category_devices(category_name)

func _ready() -> void:
	if icon_texture:
		texture_rect.texture = icon_texture
	text = category_name
