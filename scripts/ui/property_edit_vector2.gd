extends Panel

var player = null
var p_name = ""
var value = Vector2(6, 7)
@onready var label: RichTextLabel = $MarginContainer/HBoxContainer/name
@onready var x_edit: LineEdit = $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/LineEdit
@onready var y_edit: LineEdit = $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer2/LineEdit2


func _ready() -> void:
	var old_name : String = p_name
	old_name = p_name.replace("property_", "")
	old_name = old_name.replace("_", " ")
	old_name = old_name.capitalize()
	label.text = old_name
	x_edit.text = str(value.x)
	y_edit.text = str(value.y)
	x_edit.text_changed.connect(_on_trigger)
	y_edit.text_changed.connect(_on_trigger)

func _on_trigger(_argument) -> void:
	var vec = Vector2(float(x_edit.text), float(y_edit.text))
	player.set_property(p_name, vec)
