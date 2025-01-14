extends AudioStreamPlayer3D

var vol_normal = -5
var fade_duration = .5
var voltween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	volume_db = -80
#
#func _process(delta:float) -> void:
	#print(volume_db)

func start() ->void:
	voltween = get_tree().create_tween()
	voltween.tween_property(self,"volume_db",vol_normal,fade_duration)
	play()

func end() ->void:
	voltween = get_tree().create_tween()
	voltween.tween_property(self,"volume_db",-80,fade_duration)
	voltween.tween_callback(stop)
