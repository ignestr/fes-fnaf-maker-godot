extends MarginContainer

@onready var label: Label = $Label
var template = pizzeria_room.new()
@onready var button: Button = $Button


var idx : Vector2 = Vector2(0, 0)
var parent : aDeBugsLife


func _ready():
	label.text = str(int(idx.x)) + "," + str(int(idx.y))
	template.is_on = true


func _on_button_pressed() -> void:
	if parent:
		if button.button_pressed:
			print("on")
			parent.floor.rooms.get_or_add(idx, template)
		else:
			print("off")
			parent.floor.rooms.erase(idx)
