extends CharacterBody3D
class_name Player

const CAM_HEIGHT_STAND  : float = 0.5
const CAM_HEIGHT_CROUCH : float = 0.0

@export var can_debug : bool = false
@export_category("To Assign")
## Set action to change Input.mouse_mode to Input.MOUSE_MODE_VISIBLE. 
## Default is "ui_cancel", set to the Escape key.
@export_custom(PROPERTY_HINT_INPUT_NAME, "show_builtin") var input_mouse_mode  : StringName = "ui_cancel"
@export_group("Movement Actions")
@export_subgroup("Movement Keys")
@export_custom(PROPERTY_HINT_INPUT_NAME, "") var forward  : StringName
@export_custom(PROPERTY_HINT_INPUT_NAME, "") var backward : StringName
@export_custom(PROPERTY_HINT_INPUT_NAME, "") var left     : StringName
@export_custom(PROPERTY_HINT_INPUT_NAME, "") var right    : StringName
@export_subgroup("")
@export_custom(PROPERTY_HINT_INPUT_NAME, "") var sprint   : StringName
@export_custom(PROPERTY_HINT_INPUT_NAME, "") var crouch   : StringName
@export_custom(PROPERTY_HINT_INPUT_NAME, "") var jump     : StringName
@export_group("")
@export_category("Character Settings")
## Character's walk speed.
## This controls how fast the character
## walks.
@export var walk_speed    : float = 5.0
## Character's sprint speed.
## This controls how fast the character
## sprints.
@export var sprint_speed  : float = 8.0
## Character's crouch speed.
## This controls how fast the character
## moves while crouched.
@export var crouch_speed : float = 1.5
## Character's jump velocity.
## This controls how high the character
## jumps.
@export var jump_velocity : float = 4.5
## Character's sprint jump velocity.
## This controls how high the character
## jumps during sprint.
@export var sprint_jump_velocity : float = 9.0

@export_category("Camera Settings")
## Affects camera sensitivity. Ranges from 0.0 to 10.0.
@export_range(0.0, 10.0, 0.1) var camera_sensitivity : float = 5.0

@onready var yaw    : Node3D   = %Yaw
@onready var pitch  : Node3D   = %Pitch
@onready var camera : Camera3D = %Camera3D

@onready var collision_crouched   : CollisionShape3D = %CrouchedCollisionShape
@onready var collision_standing   : CollisionShape3D = %StandingCollisionShape
@onready var shape_cast_standing  : ShapeCast3D      = %ShapeCast3D

@onready var _movement_controller : Node = %MovementController

var _input_direction := Vector2.ZERO
var _direction : Vector3
var _mouse_delta := Vector2.ZERO


# Engine virtuals

func _ready() -> void:
	# Redundancy checks to avoid mistakes
	assert(self is CharacterBody3D, "This script only works within a CharacterBody3D")
	assert(camera.get_parent() == pitch, "Camera needs to be a child of pitch")
	assert(pitch.get_parent() == yaw, "Pitch needs to be a child of yaw")
	assert(yaw.get_parent() == self, "Yaw needs to be a child of this CharacterBody3D")
	camera_sensitivity = camera_sensitivity / 1000
	yaw.position.y = CAM_HEIGHT_STAND
	_movement_controller.initialize(self)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event.is_action_pressed(input_mouse_mode) and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	__camera_input(event)

func _physics_process(_delta: float) -> void:
	__player_movement()

func _process(_delta: float) -> void:
	__camera_movement()
	pass

func __camera_input(event : InputEvent) -> void:
	if event is not InputEventMouseMotion:
		return
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_mouse_delta += event.relative

func __camera_movement() -> void:
	yaw.rotate_y(-_mouse_delta.x * camera_sensitivity)
	pitch.rotate_x(-_mouse_delta.y * camera_sensitivity)
	pitch.rotation.x = clampf(pitch.rotation.x, -PI/3, PI/3)
	_mouse_delta = Vector2.ZERO

func __player_movement() -> void:
	_input_direction = Input.get_vector(left, right, forward, backward)
	_direction = (yaw.transform.basis * Vector3(_input_direction.x, 0, _input_direction.y)).normalized()
	move_and_slide()
