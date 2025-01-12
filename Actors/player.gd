extends CharacterBody3D

@onready var camera = $Camera3D

var speed = 5
var mouse_sens = .003

var active = true

func _ready():
	MouseMotion.mouse_moved.connect(rotate_camera)

func rotate_camera(displacement):
	rotation.x += -displacement.y*mouse_sens
	rotation.x = min(rotation.x, PI/3)
	rotation.x = max(rotation.x, -PI/3)
	rotation.y += -displacement.x*mouse_sens

func _physics_process(_delta):
	if active:
		var move_dir = get_input_axis()
		move_dir = move_dir.rotated(Vector3.UP, rotation.y)
		
		velocity = move_dir * speed
		move_and_slide()

func get_input_axis():
	var axis = Vector3.ZERO
	if Input.is_action_pressed("drone_forward"):
		axis.z -= 1
	if Input.is_action_pressed("drone_back"):
		axis.z += 1
	if Input.is_action_pressed("drone_left"):
		axis.x -= 1
	if Input.is_action_pressed("drone_right"):
		axis.x += 1
	return axis.normalized()
