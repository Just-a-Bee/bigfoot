extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$SubViewport/Control.player = $PlayerViewport/SubViewport/Player
	$SubViewport/Control.drone = $DroneViewport/SubViewport/Drone


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
