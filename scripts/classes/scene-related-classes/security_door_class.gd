extends WallDevice
class_name security_door

@onready var animation_tree: AnimationTree = $AnimationTree
@export var borders : Mesh
@export var door_collision_shape : CollisionShape3D

var type := TYPES.DOOR

var changing = false

var closed := false:
	set(state):
		if changing == false:
			changing = true
			closed = state
			if state == true:
				door_collision_shape.disabled = false
			else:
				door_collision_shape.disabled = true
			var tween = self.create_tween()
			tween.tween_property(animation_tree, "parameters/opening/blend_amount", int(state), 0.15).set_trans(Tween.TRANS_CIRC)
			await tween.finished
			changing = false
