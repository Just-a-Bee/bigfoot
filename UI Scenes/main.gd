extends Control

@onready var player_viewport = $PlayerViewport/SubViewport
@onready var drone_viewport = $DroneViewport/SubViewport

@onready var cam_picture = $Picture
@onready var anim = $PictureAnim
@onready var picture_cooldown = $PictureCooldown

@onready var player = $PlayerViewport/SubViewport/Player
@onready var drone = $DroneViewport/SubViewport/Drone
var is_drone_active = true

@onready var cryptids = [$Terrain/Nessie]

func _ready():
	toggle_drone()

func toggle_drone():
	is_drone_active = not is_drone_active
	if is_drone_active:
		drone.active = true
		player.active = false
		$DroneOff.hide()
		drone.position = player.position + Vector3(0,2,0)
		drone.rotation.y = player.rotation.y
		drone.velocity = Vector3.ZERO
		drone.show()
	else:
		player.active = true
		drone.active = false
		$DroneOff.show()
		drone.hide()

func _input(event):
	if event.is_action_pressed("toggle_drone"):
		toggle_drone()
		
		
	if picture_cooldown.is_stopped():
		if event.is_action_pressed("drone_picture"):
			if is_drone_active:
				take_picture(drone_viewport, drone)
				anim.play("drone_picture")
		if event.is_action_pressed("player_picture"):
			take_picture(player_viewport, player)
			anim.play("player_picture")

func take_picture(viewport, taker):
	var texture = viewport.get_texture().get_image()
	texture = ImageTexture.create_from_image(texture)
	cam_picture.texture = texture
	
	var picture = {"texture" : texture, "score" : 0, "strings" : [], "target" : null}
	# picture has "texture", "score", "strings"
	score_picture(picture, taker)
	
	picture_cooldown.start()

# picture scoring is done based on current transform of actors
func score_picture(picture, taker):
	#iterate over cryptids, keeps highest scoring
	#technically could get strings from other cryptid scoring, but seems unlikely it would happen
	for c in cryptids:
		#continue if nessie is underwater
		if c is Nessie and c.hidden:
			continue
		var score = 0
		var distance = c.global_position - taker.camera.global_position
		var taker_dir = -taker.camera.get_global_transform().basis.z
		
		var dot = taker_dir.dot(distance.normalized())
		
		# actual scoring, adds strings to display when explaining score
		if distance.length() < 50 && dot > .8:
			if distance.length() < 10:
				score += 2
				picture["strings"].append("Very close: +2")
			elif distance.length() < 20:
				score += 1
				picture["strings"].append("Quite close: +1")
			if dot > .95:
				score += 2
				picture["strings"].append("Dead on: +2")
			score += 1
			picture["strings"].append("Good: +1")
		if score > picture["score"]:
			picture["score"] = score
			picture["target"] = c
