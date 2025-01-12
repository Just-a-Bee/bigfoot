extends Node3D

var mouse_sens = .003

func _ready():
	MouseMotion.mouse_moved.connect(rotate_camera)

func rotate_camera(displacement):
	rotation.x += -displacement.y*mouse_sens
	rotation.y += -displacement.x*mouse_sens
