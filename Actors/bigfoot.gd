extends CharacterBody3D
class_name Bigfoot

@export var player:Node
@export var drone:Node

var speed = 8
var gravity = 3
var height = 3.5

var last_seen_player_pos:Vector3 = Vector3.ZERO
var alertness:float = 0
var alert_time = 3

func _physics_process(delta):
	alertness -= delta # decrement alertness
	spot_player_actors() # try to spot the player
	
	var move_dir = Vector3.ZERO # direction to move horizontally in
	
	if alertness > 0:
		move_dir = (global_position - last_seen_player_pos)
		move_dir.y = 0
		move_dir = move_dir.normalized()
		
	velocity = move_dir * speed
	var velocity2D = Vector3(velocity.x, 0, velocity.z)
	rotation.y = velocity2D.angle_to(-Vector3.FORWARD)
	
	# apply gravity and move
	velocity.y -= gravity
	move_and_slide()


# function to spot the player and drone
# sets alertness if one is spotted
# sets last seen position to average of spotted actor positions
func spot_player_actors():
	
	var forward_dir = -get_global_transform().basis.z
	
	var distance_player = player.global_position - global_position
	var dot_player = forward_dir.dot(-distance_player.normalized())
	
	var distance_drone = drone.global_position - global_position
	var dot_drone = forward_dir.dot(-distance_drone.normalized())
	
	var player_seen = false
	var drone_seen = false
	
	if distance_player.length() < 30 and dot_player > .6:
		player_seen = true
	if distance_player.length() < 10:
		player_seen = true
	if distance_drone.length() < 30 and dot_drone > .6 and drone.active:
		drone_seen = true
	if distance_drone.length() < 10 and drone.active:
		drone_seen = true
	
	last_seen_player_pos = Vector3.ZERO
	
	if player_seen:
		last_seen_player_pos += player.global_position
		print("I see you ", dot_player)
		alertness = alert_time
	if drone_seen:
		last_seen_player_pos += drone.global_position
		print("I see drone ", dot_drone)
		alertness = alert_time
	if player_seen and drone_seen:
		last_seen_player_pos = last_seen_player_pos/2 # average them if both seen
	if not player_seen and not drone_seen:
		print("I do not see")
	
