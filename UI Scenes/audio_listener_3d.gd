extends AudioListener3D
@onready var player = $"../PlayerViewport/SubViewport/Player"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	make_current()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#position = player.position
	pass
