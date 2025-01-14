extends CharacterBody3D
class_name Bigfoot

@export var player:Node
@export var drone:Node

var walk_speed = 2
var run_speed = 8
var gravity = 3
var height = 3.5

var last_seen_player_pos:Vector3 = Vector3.ZERO
var alertness:float = 0
var alert_time = 3

@export var patrol_points:Array[Node3D] = []
var patrol_index = 0

enum states {
	patrol = 0,
	look = 1,
	run = 2
}
var state = states.patrol

func _physics_process(delta):
	alertness = move_toward(alertness, 0, delta) # decrement alertness
	spot_player_actors(delta) # try to spot the player
	var move_vector = Vector3.ZERO # direction to move horizontally in
	
	
	
	if alertness > 5:
		if state != states.run:
			change_state(states.run)
		move_vector = run_away()
	elif alertness > 2:
		if state != states.look:
			change_state(states.look)
		pass # do looking around
	else:
		if state != states.patrol:
			change_state(states.patrol)
		move_vector = patrol()
	
	# generate velocity, look in move direction, apply gravity, move
	velocity = move_vector
	if move_vector.length() > 0:
		look_at(global_position - move_vector)
	velocity.y -= gravity
	move_and_slide()

func run_away()->Vector3:
	var move_dir = (global_position - last_seen_player_pos)
	move_dir.y = 0
	move_dir = move_dir.normalized() * run_speed
	return move_dir

func patrol()->Vector3:
	var patrol_distance = patrol_points[patrol_index].global_position - global_position
	var patrol_distance2D = Vector3(patrol_distance.x, 0, patrol_distance.z)
	if (abs(patrol_distance2D.length()) < 1):
		patrol_index += 1
		if patrol_index >= patrol_points.size():
			patrol_index = 0
		patrol_distance = patrol_points[patrol_index].global_position - global_position
	
	var move_dir = (patrol_distance)
	move_dir.y = 0
	move_dir = move_dir.normalized()
	return move_dir * walk_speed

func change_state(newState):
	state = newState
	if newState == states.run:
		$Model.switch_face(2)
		$Model.play_anim("run")
	if newState == states.look:
		$Model.switch_face(0 + randi_range(0, 1))
		$Model.play_anim("walk-slow")
	if newState == states.patrol:
		$Model.switch_face(3 + randi_range(0,1))
		$Model.play_anim("walk-normal")

# function to spot the player and drone
# sets alertness if one is spotted
# sets last seen position to average of spotted actor positions
func spot_player_actors(delta):
	
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
		alertness += 5 * delta
	if drone_seen:
		last_seen_player_pos += drone.global_position
		alertness += 5 * delta
	if player_seen and drone_seen:
		last_seen_player_pos = last_seen_player_pos/2 # average them if both seen
