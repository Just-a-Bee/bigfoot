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
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", showingPosition, 2)
	hidden = false
	$Timer.start(3 + randi_range(-2, 2))
	

func go_under():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", hidingPosition, 2)
	await tween.finished
	hidden = true
	$Timer.start(15 + randi_range(-10, 10))

func stop_showing():
	go_under()
	$Timer.timeout.disconnect(_on_timer_timeout)
	
