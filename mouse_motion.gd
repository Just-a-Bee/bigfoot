# Singleton to handle mouse movement, as it gets weird within the SubViewports
# Accessed by player.gd

extends Node

signal mouse_moved

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		mouse_moved.emit(event.relative) # on motion emit signal
	
	if (event.is_action("ui_cancel") ):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) # on escape release mouse
	
	if (event is InputEventMouseButton):
		if event.button_index == 1:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) # on click capture
