extends AudioStreamPlayer3D

@export var bigfoot:Node
@export var player:Node
@export var drone:Node

func _process(_delta):
	var listener = player
	if drone.active:
		var player_dist = bigfoot.global_position - player.global_position
		var drone_dist = bigfoot.global_position - drone.global_position
		if drone_dist.length() < player_dist.length():
			listener = drone
			print("drone listening")
	
	position = bigfoot.global_position - listener.global_position
	#print(position)
	
