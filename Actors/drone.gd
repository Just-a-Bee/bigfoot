extends CharacterBody3D
class_name Drone

const drone_range = 60
const range_tolerance = 10

const spawn_offset:Vector3 = Vector3(0, 10, -2)
const crash_velocity = 4.9

const camera_normal_rotation = -20
const camera_ground_rotation = 5
const camera_normal_z_pos = -0.12
const camera_ground_z_pos = -0.3

signal next_battery_frame
signal crash

@export var main:Node
@export var player:Node
@onready var camera = $CameraParent/Camera3D
var active = false

# speed vars
var horizontal_acc = 12
var vertical_acc = 20
var turn_acc = 2
# movement max speeds
var horizontal_max = 9
var vertical_max = 5
var turn_max = 3
# slowing down vars
var gravity = 10
var air_resistance = 2
var floor_resistance = 20
var turn_slowing = .5

var turn_velocity = 0 # current turning velocity
var velocity_factor = 1 # factor to multiply velocity by, decreases when out of battery/range


# battery life vars
var battery_unit = 60
var battery_life = (5 * battery_unit) - .01 # subtract .01 to prevent first battery loss event

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	if not active:
		return
	
	# update variables
	update_cam_rotation()
	update_battery_life(delta)
	update_velocity_factor()
	
	# Do player movement
	var move_axis = get_move_axis()
	
	handle_turning(move_axis, delta)
	handle_horizontal_move(move_axis, delta)
	handle_vertical_move(move_axis, delta)
	
	# handle crashing
	var pre_velocity = velocity
	var collision = move_and_slide()
	if should_crash(collision,pre_velocity):
		main.toggle_drone()
		$CrashSound.play()
		crash.emit()
	# clamp position to bounds
	global_position.x = clamp(global_position.x, -100, 100)
	global_position.z = clamp(global_position.z, -93.2, 106.8)
	global_position.y = min(global_position.y, 40)
	
	#move the drone AudioStreamPlayer3D to the new position, relative to the player's position
	$"../../../PlayerViewport/SubViewport/DroneLoopPlayer3D".position = (position - $"../../../PlayerViewport/SubViewport/Player".position).rotated(Vector3(0,1,0),$"../../../PlayerViewport/SubViewport/Player".rotation.y)
	$"../../../PlayerViewport/SubViewport/LakeLoopPlayer3D".position = ($"../../../PlayerViewport/SubViewport/LakeLoopPlayer3D".world_coord - position).rotated(Vector3(0,1,0),rotation.y)

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

func handle_turning(move_axis, delta):
	# do turning
	turn_velocity = move_toward(turn_velocity, turn_max * move_axis.x, turn_acc * delta)
	rotation.y += turn_velocity # rotate left/right
	turn_velocity = move_toward(turn_velocity, 0, turn_slowing)
func handle_horizontal_move(move_axis, delta):
	# add velocity based on input
	var forward_dir = Vector3.FORWARD.rotated(up_direction, rotation.y)
	var velocity2D = Vector3(velocity.x, 0, velocity.z)
	velocity2D = velocity2D.move_toward(horizontal_max * forward_dir * move_axis.z, horizontal_acc * delta * velocity_factor)
	velocity.x = velocity2D.x 
	velocity.z = velocity2D.z
	# approach 0
	velocity -= velocity2D.normalized() * air_resistance * delta
	if is_on_floor():
		velocity -= velocity2D.normalized() * floor_resistance * delta
func handle_vertical_move(move_axis, delta):
	var up_force = move_axis.y * vertical_acc * velocity_factor
	velocity.y = move_toward(velocity.y, vertical_max, up_force * delta)
	velocity.y = move_toward(velocity.y, -vertical_max, gravity * delta) # Do gravity
	

#code source: https://datascience.oneoffcoder.com/s-curve.html
func logistic(x, L=1, x_0=0, k=1):
	x*=12
	x-=6
	x_0*=12
	x_0-=6
	
	return L / (1 + exp(-k * (x - x_0)))

# function to adjust the camera's rotation, based on distance to the floor
func update_cam_rotation():
	var floor_distance:float = (position.y - $RayCast3D.get_collision_point().y)
	floor_distance -= .25
	floor_distance *= .25
	floor_distance=logistic(floor_distance,1,.1,.3)
	
	floor_distance = clampf(floor_distance, 0, 1)
	
	$CameraParent.rotation_degrees.x = lerp(camera_ground_rotation, camera_normal_rotation, floor_distance*2)
	$CameraParent.position.z = lerp(camera_ground_z_pos, camera_normal_z_pos, floor_distance*2)
	
func update_battery_life(delta):
	var original_life = battery_life
	battery_life -= delta
	if (int(original_life)/ battery_unit > battery_life / battery_unit):
		next_battery_frame.emit()
	

# function to update velocity factor based on
# things that should slow drone down
func update_velocity_factor():
	velocity_factor = 1
	# when battery depleted, drone slows down
	if battery_life < 0:
		velocity_factor = -battery_life / (battery_unit/4)
	var distance = (position - player.position).length()
	if ( distance > drone_range):
		velocity_factor = lerp(velocity_factor, 0, (distance - drone_range)/range_tolerance)
	

# boolean function to return if drone should crash
func should_crash(collision, vel)->bool:
	if (collision and vel.length() > crash_velocity):
		return true
	if collision and battery_life < 0:
		return true
	if position.y < -7.5:
		return true
	return false


func activate(player_position, player_rotation):
	rotation.y = player_rotation
	position = player_position + spawn_offset.rotated(Vector3.UP, player_rotation)
	$RayCast3D.force_raycast_update()
	position = $RayCast3D.get_collision_point() + Vector3.UP
	velocity = Vector3.ZERO
	battery_life = (5 * battery_unit) - .01 # subtract .01 to prevent first battery loss event
	show()
