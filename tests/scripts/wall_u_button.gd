extends MarginContainer

@onready var label: Label = $Label
var template = pizzeria_wall.new()
@onready var button: Button = $Button


var idx : Vector2i = Vector2(0, 0)
var parent : aDeBugsLife


func _ready():
	label.text = str(int(idx.x)) + "," + str(int(idx.y))
	template.base_set_type(template.WALL_TYPES.FLAT)

func _on_button_pressed() -> void:
	if parent:
		if parent.mode == 1:
			parent.selected_idx = Vector3(idx.x, idx.y, 0)
		if button.button_pressed:
			if parent.mode == 0:
				parent.floor.walls.get_or_add(Vector3(idx.x, idx.y, 0), template)
		else:
			if parent.mode == 0:
				parent.floor.walls.erase(Vector3(idx.x, idx.y, 0))
