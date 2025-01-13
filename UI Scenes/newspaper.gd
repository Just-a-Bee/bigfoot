extends PanelContainer

@onready var top = $MarginContainer/VBoxContainer/Top
@onready var photo = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/TextureRect

func _ready():
	add_date()

func set_perfect(picture):
	$MarginContainer/VBoxContainer/PerfectTitle.show()
	$MarginContainer/VBoxContainer/HBoxContainer/PerfectBody.show()
	picture.set_size_override(Vector2i(144, 162))
	photo.texture = picture

func set_okay(picture):
	$MarginContainer/VBoxContainer/OkayTitle.show()
	$MarginContainer/VBoxContainer/HBoxContainer/OkayBody.show()
	picture.set_size_override(Vector2i(144, 162))
	photo.texture = picture

func set_bad(picture):
	$MarginContainer/VBoxContainer/BadTitle.show()
	$MarginContainer/VBoxContainer/HBoxContainer/BadBody.show()
	picture.set_size_override(Vector2i(144, 162))
	photo.texture = picture

func add_date():
	var date = Time.get_datetime_dict_from_system()
	top.text += str(date["month"]) + "/" + str(date["day"]) + "/" + str(date["year"])
