# Singleton to handle mouse movement, as it gets weird within the SubViewports
# Accessed by player.gd

extends Node

var is_main_loaded = false
signal mouse_moved

func _ready():
	pass

func _input(event):
	if event is InputEventMouseMotion:
		mouse_moved.emit(event.relative) # on motion emit signal
	
	if (event.is_action("ui_cancel") ):
		if is_main_loaded:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) # on escape release mouse
	
