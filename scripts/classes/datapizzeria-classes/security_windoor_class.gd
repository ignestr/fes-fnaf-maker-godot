extends wall_device
class_name security_doorwindow

@onready var animation_tree: AnimationTree = $AnimationTree
@export var borders : Mesh
@export var collision_shape : CollisionShape3D
@export var window_cutout : CSGBox3D
@export var window_offset : Vector3

var type := TYPES.WINDOOR

var changing = false

var closed := false:
	set(state):
		if changing == false:
			changing = true
			closed = state
			if state == true:
				collision_shape.disabled = false
			else:
				collision_shape.disabled = true
			var tween = self.create_tween()
			tween.tween_property(animation_tree, "parameters/opening/blend_amount", int(state), 0.15).set_trans(Tween.TRANS_CIRC)
			await tween.finished
			changing = false
			

func _ready() -> void:
	closed = false
