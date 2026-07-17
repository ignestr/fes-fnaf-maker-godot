extends wall_device
class_name security_door

@onready var animation_tree: AnimationTree = $AnimationTree
@export var borders : Mesh
@export var collision_shape : CollisionShape3D

var type := TYPES.DOOR

var changing = false

var closed := false:
	set(state):
		print("attempted")
		if changing == false:
			changing = true
			closed = state
			if state == true:
				collision_shape.disabled = false
			else:
				collision_shape.disabled = true
			print("did")
			var tween = self.create_tween()
			tween.tween_property(animation_tree, "parameters/opening/blend_amount", int(state), 0.15).set_trans(Tween.TRANS_CIRC)
			await tween.finished
			changing = false
			
