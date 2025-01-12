extends Node3D
class_name Nessie

@export var hidingPosition:Vector3
@export var showingPosition:Vector3
var hidden = true

func _ready():
	go_under()

func _on_timer_timeout():
	if hidden:
		pop_up()
	else:
		go_under()

func pop_up():
	position = showingPosition
	$Timer.start(3 + randi_range(-2, 2))
	hidden = false

func go_under():
	position = hidingPosition
	$Timer.start(15 + randi_range(-10, 10))
	hidden = true
