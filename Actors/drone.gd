extends CharacterBody3D

@onready var camera = $Camera3D
var active = false

# speed vars
var horizontal_acc = 6
var vertical_acc = 3
var turn_acc = 2
# movement max speeds
var horizontal_max = 6
var vertical_max = 5
var turn_max = 3
# slowing down vars
var gravity = 1
var air_resistance = 2
var floor_resistance = 20
var turn_slowing = .5

var turn_velocity = 0 # current turning velocity



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	if not active:
		return
	
	# Do player movement
	var move_axis = get_move_axis()
	
	# do turning
	turn_velocity = move_toward(turn_velocity, turn_max * move_axis.x, turn_acc * delta)
	rotation.y += turn_velocity # rotate left/right
	
	# do forward/back
	var forward_dir = Vector3.FORWARD.rotated(up_direction, rotation.y)
	velocity += forward_dir * move_axis.z * horizontal_acc * delta # add forward/back
	var velocity2D = Vector3(velocity.x, 0, velocity.z)
	if velocity2D.length() > horizontal_max:
		velocity2D = velocity2D.normalized() * horizontal_max # limit to horizontal_max
	
	# Add up movement
	velocity.y = move_toward(velocity.y, vertical_max, move_axis.y * vertical_acc * delta)
	
	# Other forces
	velocity.y = move_toward(velocity.y, -vertical_max, gravity * delta) # Do gravity
	velocity -= velocity2D.normalized() * air_resistance * delta
	if is_on_floor():
		velocity -= velocity2D.normalized() * floor_resistance * delta
	turn_velocity = move_toward(turn_velocity, 0, turn_slowing)
	
	var collision = move_and_slide()
	if collision:
		pass # TODO: drone crash

func get_move_axis()->Vector3:
	var move_axis:Vector3 = Vector3.ZERO
	
	if Input.is_action_pressed("drone_forward"):
		move_axis.z += 1
	if Input.is_action_pressed("drone_back"):
		move_axis.z -= 1
	if Input.is_action_pressed("drone_left"):
		move_axis.x += 1
	if Input.is_action_pressed("drone_right"):
		move_axis.x -= 1
	if Input.is_action_pressed("drone_up"):
		move_axis.y += 1
	
	return move_axis
