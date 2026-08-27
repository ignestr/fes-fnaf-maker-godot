extends Panel

var player
var p_name
var value

@onready var label: RichTextLabel = $MarginContainer/HBoxContainer/name
@onready var button: CheckButton = $MarginContainer/HBoxContainer/CheckButton

func _ready() -> void:
	var old_name : String = p_name
	old_name = p_name.replace("property_", "")
	old_name = old_name.replace("_", " ")
	old_name = old_name.capitalize()
	label.text = old_name
	button.button_pressed = value
	button.pressed.connect(_on_trigger)


func _on_trigger() -> void:
	player.set_property(p_name, button.button_pressed)
