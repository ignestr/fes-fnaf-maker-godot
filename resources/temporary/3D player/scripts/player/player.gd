extends CharacterBody3D


# Ignore this code, it was imported from an old project
# it's just for examining scenes more easily
# before making a proper character controller

# References
@onready var head = $Head
@onready var viewport = $Head/Camera3D
@onready var climb_hit = $CollisionShape3D/Area3D
@onready var fsm = $FSM
@onready var climb_ray_2 = $CollisionShape3D/ClimbRay2


# Params
@export var BASE_SPEED = 5.0
@export var SPEED = 5.0
@export var JUMP_VELOCITY = 4.5
@export var SENSITIVITY = 0.005
@export var SPRINT_SPEED = 12
@export var FLOAT_SPEED = 4.0

# States
var sprinting = false # will increase velocity by sprint speed on the ground
var swimming = false # basically flies but with some dampening and slight gravity
var flying  = false #much differently scoped flying behavior
var stopped  = false# cutscene state
var crawling = false # slows the player down by at least half
var sliding  = false# sprinting speed with crawling size
var canSprint = true
var lookingInventory = false

# Properties
var health = 1000
var float_damp = 0 # How dampened floating movement will be


# Misc Logic vars
var onTask = false
var paused
var mouseOnTask
var isMoving
var lastState
var dBounce = false

var noclipped = false

# Mouse vars
var rot_x = 0
var rot_y = 0

# Functional functions

func wasdGroundMove(givenSpeed = SPEED):
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "fwrd", "back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction and onTask == false:
		velocity.x = direction.x * givenSpeed
		velocity.z = direction.z * givenSpeed
	elif onTask == false:
		velocity.x = move_toward(velocity.x, 0, givenSpeed)
		velocity.z = move_toward(velocity.z, 0, givenSpeed)


# Behavior



func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	# Mouse movement
	
	
	
	if event is InputEventMouseMotion and not(mouseOnTask or paused):
			# modify accumulated mouse rotation
			rot_x += -event.relative.x * SENSITIVITY
			rot_y += -event.relative.y * SENSITIVITY
			
			rot_y = clamp(rot_y, deg_to_rad(-90), deg_to_rad(110))
			transform.basis = Basis()
			head.transform.basis = Basis() # reset rotation
			rotate_object_local(Vector3(0, 1, 0), clamp(rot_x, -90, 90)) # first rotate in Y
			head.rotate_object_local(Vector3(1, 0, 0), clamp(rot_y, -90, 90)) # then rotate in X
	
	# Sprint
	if Input.is_action_just_pressed("shift") and fsm.cur_state.name == "general" and canSprint and not onTask and isMoving:
		fsm.state("sprint", "Player")
	if Input.is_action_just_released("shift"):
		fsm.state("general", "Player")
	
	if Input.is_action_just_pressed("noclip"):
		if noclipped == false:
			fsm.state("float", "Player")
			noclipped = true
			print("yuh")
		else:
			fsm.state("general", "Player")
			noclipped = false
	
	# Crawl and Slide
	
	# CATCH THE DEFAULTING TO SPRINT BUG
	
	if Input.is_action_just_pressed("ctrl") and not onTask:
		lastState = fsm.cur_state.name
		if fsm.cur_state.name == "sprint":
			# await get_tree().current_scene.get_child(1).create_timer(0.5).timeout
			if not is_on_floor():
				await get_tree().create_timer(0.2).timeout
				fsm.state("slide", "Player")
				print("awaited")
			else:
				fsm.state("slide", "Player")
		else:
			fsm.state("crawl", "Player")
	if Input.is_action_just_released("ctrl"):
		fsm.state(lastState, "Player")
	
	# Holding on to ledges
	
	if Input.is_action_just_pressed("space"):
		velocity += Vector3.UP * JUMP_VELOCITY
	
	
	# Inventory
	
	# Pause

	
	if Input.is_action_just_pressed("escape"):
		get_viewport().gui_release_focus()
		if not paused:
			paused = true
			onTask = true
			mouseOnTask = true
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			paused = false
			onTask = false
			mouseOnTask = false
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _physics_process(delta):
	# This is checked because gravity works differently in these two states
	if not is_on_floor() and not (flying or swimming):
		velocity += get_gravity() * delta
	move_and_slide()

func _process(delta):
	var input_dir = Input.get_vector("left", "right", "fwrd", "back")
	if input_dir != Vector2.ZERO:
		isMoving = true
	else:
		isMoving = false
	# Calculation of the different properties
	
	
	
