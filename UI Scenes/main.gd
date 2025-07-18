extends Control

@onready var player_viewport = $PlayerViewport/SubViewport
@onready var drone_viewport = $DroneViewport/SubViewport

@onready var camera_sound = $CameraSound
@onready var cam_picture = $UINodes/Picture
@onready var anim = $PictureAnim
@onready var picture_cooldown = $PictureCooldown

@onready var player = $PlayerViewport/SubViewport/Player
@onready var drone = $DroneViewport/SubViewport/Drone
var is_drone_active = true

@onready var nessie = $Terrain/Nessie
@onready var bigfoot = $Terrain/Bigfoot

@onready var film_rect = $UINodes/Film
var film_remaining = 8
@onready var end_timer = $EndTimer

@onready var drone_battery = $UINodes/Battery

func _ready():
	GameData.pictures.clear()
	MouseMotion.is_main_loaded = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	toggle_drone()

func toggle_drone():
	if drone.battery_life < 0:
		return
	is_drone_active = not is_drone_active
	if is_drone_active:
		drone.active = true
		player.active = false
		$DroneOff.hide()
		drone.activate(player.position, player.rotation.y)
		$PlayerViewport/SubViewport/DroneLoopPlayer3D.start()
	else:
		player.active = true
		drone.active = false
		$DroneOff.show()
		drone.hide()
		$PlayerViewport/SubViewport/DroneLoopPlayer3D.end()

func _input(event):
	if event.is_action_pressed("toggle_drone"):
		toggle_drone()
		
		
	if picture_cooldown.is_stopped() and film_remaining > 0 and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if event.is_action_pressed("drone_picture"):
			if is_drone_active:
				take_picture(drone_viewport, drone)
				anim.play("drone_picture")
		if event.is_action_pressed("player_picture"):
			take_picture(player_viewport, player)
			anim.play("player_picture")
	if (event is InputEventMouseButton):
		if event.button_index == 1:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) # on click capture

# update drone distance bar
func _process(_delta):
	var drone_dist = (drone.position - player.position).length()
	var dist_value = lerp(100, 0, drone_dist / drone.drone_range)
	$UINodes/DroneDistanceBar.value = dist_value
	$UINodes/DistanceWarning.visible = dist_value < 5

func take_picture(viewport, taker):
	camera_sound.play()
	var texture = viewport.get_texture().get_image()
	texture = ImageTexture.create_from_image(texture)
	cam_picture.texture = texture
	
	var picture = {"texture" : texture, "score" : 0, "strings" : []}
	# picture has "texture", "score", "strings"
	score_picture(picture, taker)
	
	GameData.pictures.append(picture)
	
	film_remaining -= 1
	film_rect.size.x = film_remaining * 32
	if (film_remaining == 0):
		film_rect.hide()
		end_timer.start()
	
	picture_cooldown.start()

# picture scoring is done based on current transform of actors
func score_picture(picture, taker):
	#iterate over cryptids, keeps highest scoring
	#technically could get strings from other cryptid scoring, but seems unlikely it would happen
	
	var taker_dir = -taker.camera.get_global_transform().basis.z
	var distance
	var dot
	
	var distance_nessie = nessie.global_position - taker.camera.global_position
	var dot_nessie =  taker_dir.dot(distance_nessie.normalized())
	
	var distance_bigfoot = bigfoot.global_position + Vector3(0,bigfoot.height/2,0) - taker.camera.global_position
	var dot_bigfoot = taker_dir.dot(distance_bigfoot.normalized())
	
	# figure out who the picture is of
	var subject = null
	if distance_nessie.length() < 50 && dot_nessie > .8 && nessie.hidden == false:
		subject = nessie
		distance = distance_nessie
		dot = dot_nessie
	elif distance_bigfoot.length() < 50 && dot_bigfoot > .8:
		subject = bigfoot
		distance = distance_bigfoot
		dot = dot_bigfoot
		
	
	if subject == null:
		picture["strings"].push_back("Bad.")
	else:
		var looking_at_camera = -taker_dir.dot(subject.get_global_transform().basis.z)
		var score = 0
		score += 1
		picture["strings"].append("Good: +1")
		
		if subject == nessie:
			score += 3
			picture["strings"].append("Nessie: +3")
			nessie.stop_showing()
		
		if distance.length() < 5:
			score += 2
			picture["strings"].append("Very close: +2")
		elif distance.length() < 15:
			score += 1
			picture["strings"].append("Quite close: +1")
		if dot > .98:
			score += 2
			picture["strings"].append("Dead on: +2")
		if looking_at_camera > .8:
			score += 2
			picture["strings"].append("Say Cheese: +2")
		
		picture["score"] = score


func _on_end_timer_timeout():
	get_tree().change_scene_to_file("res://UI Scenes/end.tscn")


func _on_drone_crash():
	$DroneCrashAnim.show()
	$DroneCrashAnim.play()
	await $DroneCrashAnim.animation_finished
	$DroneCrashAnim.hide()
	$"Battery-loop".stop()


@onready var batt_low_loop = preload("res://assets/audio/drone/battery-low-loop.wav")
@onready var batt_dead_loop = preload("res://assets/audio/drone/battery-dead-loop.wav")

func _on_drone_next_battery_frame():
	if drone_battery.frame_coords.x < drone_battery.hframes - 1:
		drone_battery.frame_coords.x += 1
	if(drone_battery.frame_coords.x == 4):
		$"Battery-loop".stream = batt_low_loop
		$"Battery-loop".play()
	elif (drone_battery.frame_coords.x == 5):
		if $"Battery-loop".stream == batt_low_loop:
			$"Battery-loop".stream = load("res://assets/audio/battery-dead-loop.wav")
			$"Battery-loop".play()
