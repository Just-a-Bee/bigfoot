extends Control

@onready var player_viewport = $Control/SubViewportContainer/SubViewport
@onready var drone_viewport = $Control/CenterContainer/SubViewportContainer2/SubViewport

@onready var cam_picture = $Picture
@onready var anim = $PicutreAnim
@onready var picture_cooldown = $PictureCooldown

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _input(event):
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
