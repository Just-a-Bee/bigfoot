extends CharacterBody3D
class_name Bigfoot

@onready var rayCasts = [$Ray1, $Ray2, $Ray3, $Ray4, $Ray5,$Ray6, $Ray7, $Ray8]

@export var player:Node
@export var drone:Node
@export var yell_sound:Node
@export var step_sound:Node
@export var idle_sound:Node

var slow_walk_speed = 2
var walk_speed = 2.5
var run_speed = 12
var gravity = 3
var height = 3.5

var footstepTime = 0
var footstepMax = 3

var last_seen_player_pos:Vector3 = Vector3.ZERO
var last_away_wall_dir:Vector3
var alertness:float = 0
var alert_time = 3
var is_escaping_corner:bool = false

@export var patrol_points:Array[Node3D] = []
var patrol_index = 0

enum states {
	patrol = 0,
	look = 1,
	run = 2
}
var state = states.patrol

func _ready():
	change_state(states.patrol)

func _physics_process(delta):
	
	if global_position.y < -10:
		position = patrol_points[patrol_index].global_position
		print("Bigfoot fell out")
	
	alertness = move_toward(alertness, 0, delta) # decrement alertness
	spot_player_actors(delta) # try to spot the player
	
	var move_vector = Vector3.ZERO # direction to move horizontally in
	
	
	
	if alertness > 5:
		if $YellCooldown.is_stopped():
			yell_sound.play()
			$YellCooldown.start()
		if state != states.run:
			change_state(states.run)
		move_vector = run_away()
	elif alertness > 2:
		if state != states.look:
			change_state(states.look)
		look_around()
	else:
		if state != states.patrol:
			change_state(states.patrol)
		move_vector = patrol()
		if $IdleCooldown.is_stopped():
			idle_sound.play()
			$IdleCooldown.start()
	
	# generate velocity, look in move direction, apply gravity, move
	velocity = move_vector
	
	footstepTime += move_vector.length() * delta
	if footstepTime > footstepMax:
		footstepTime -= footstepMax
		step_sound.play()
	
	
	
	if move_vector.length() > 0:
		look_at(global_position - move_vector)
	velocity.y -= gravity
	move_and_slide()

func run_away()->Vector3:
	var away_player_dir = (global_position - last_seen_player_pos).normalized()
	var away_wall_dir = Vector3.ZERO
	var count = 0
	for r in rayCasts:
		if r.is_colliding():
			var wall_distance = global_position - r.get_collision_point()
			wall_distance.y = 0
			away_wall_dir += (wall_distance).normalized() * (1-wall_distance.length()/10)
			count += 1
	if (count > 3):
		is_escaping_corner = true
		$CornerTimer.start()
	if (count == 0 and is_escaping_corner):
		away_wall_dir = last_away_wall_dir
	
	var move_dir = away_wall_dir
	if (!is_escaping_corner):
		move_dir += away_player_dir
	
	
	move_dir.y = 0
	move_dir = move_dir.normalized() * run_speed
	last_away_wall_dir = away_wall_dir
	return move_dir

func look_around()->Vector3:
	var away_player_dir = (global_position - last_seen_player_pos).normalized()
	var move_vector = -away_player_dir
	move_vector.y = 0
	move_vector = move_vector * slow_walk_speed
	
	return move_vector

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
		alertness = 10
	if newState == states.look:
		$Model.switch_face(0 + randi_range(0, 1))
		$Model.play_anim("walk-slow")
	if newState == states.patrol:
		$Model.switch_face(3 + randi_range(0,1))
		$Model.play_anim("walk-normal")
		var position2D = Vector3(global_position.x, 0, global_position.z)
		var closest_point = patrol_points[0]
		var closest_dist = position2D - closest_point.global_position
		for point in patrol_points:
			var point_dist = position2D - point.global_position
			if point_dist.length() < closest_dist.length():
				closest_point = point
				closest_dist = point_dist
		patrol_index = patrol_points.find(closest_point)

# function to spot the player and drone
# sets alertness if one is spotted
# sets last seen position to average of spotted actor positions
func spot_player_actors(delta):
	
	var forward_dir = -get_global_transform().basis.z
	
	var distance_player = player.global_position - global_position
	var dot_player = forward_dir.dot(-distance_player.normalized())
	
	var distance_drone = drone.global_position - global_position
	var dot_drone = forward_dir.dot(-distance_drone.normalized())
	
	var player_seen = 0
	var drone_seen = 0
	
	if distance_player.length() < 30 and dot_player > .6:
		player_seen += 1
	if distance_player.length() < 10:
		player_seen += 1
	if distance_drone.length() < 30 and dot_drone > .6 and drone.active:
		drone_seen += 1
	if distance_drone.length() < 10 and drone.active:
		drone_seen += 1
	
	alertness = move_toward(alertness, 10, (player_seen + drone_seen) * 5 * delta) 
	
	if player_seen and not drone_seen:
		last_seen_player_pos = player.global_position
		alertness += 5 * delta
	if drone_seen and not player_seen:
		last_seen_player_pos = drone.global_position
		alertness += 5 * delta
	if player_seen and drone_seen:
		last_seen_player_pos = (player.global_position + drone.global_position)/2
		last_seen_player_pos = last_seen_player_pos/2 # average them if both seen


func _on_corner_timer_timeout():
	is_escaping_corner = false
