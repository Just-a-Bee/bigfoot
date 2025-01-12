extends Control

@onready var player_viewport = $PlayerViewport/SubViewport
@onready var drone_viewport = $DroneViewport/SubViewport

@onready var cam_picture = $Picture
@onready var anim = $PictureAnim
@onready var picture_cooldown = $PictureCooldown

@onready var player = $PlayerViewport/SubViewport/Player
@onready var drone = $DroneViewport/SubViewport/Drone
var is_drone_active

func _input(event):
	if event.is_action_pressed("toggle_drone"):
		is_drone_active = not is_drone_active
		if is_drone_active:
			drone.active = true
			$DroneOff.hide()
		else:
			player.active = true
			$DroneOff.show()
		
		
	if picture_cooldown.is_stopped():
		if event.is_action_pressed("drone_picture"):
			var texture = drone_viewport.get_texture().get_image()
			texture = ImageTexture.create_from_image(texture)
			cam_picture.texture = texture
			anim.play("drone_picture")
			picture_cooldown.start()
		if event.is_action_pressed("player_picture"):
			var texture = player_viewport.get_texture().get_image()
			texture = ImageTexture.create_from_image(texture)
			cam_picture.texture = texture
			anim.play("player_picture")
			picture_cooldown.start()
