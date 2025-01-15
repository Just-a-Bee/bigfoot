extends PanelContainer

@onready var top = $MarginContainer/VBoxContainer/Top
@onready var photo = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/TextureRect

var image

func _ready():
	add_date()

func set_model(picture):
	$MarginContainer/VBoxContainer/ModelTitle.show()
	$MarginContainer/VBoxContainer/HBoxContainer/ModelBody.show()
	image = picture

func set_perfect(picture):
	$MarginContainer/VBoxContainer/PerfectTitle.show()
	$MarginContainer/VBoxContainer/HBoxContainer/PerfectBody.show()
	image = picture

func set_okay(picture):
	$MarginContainer/VBoxContainer/OkayTitle.show()
	$MarginContainer/VBoxContainer/HBoxContainer/OkayBody.show()
	image = picture

func set_bad(picture):
	$MarginContainer/VBoxContainer/BadTitle.show()
	$MarginContainer/VBoxContainer/HBoxContainer/BadBody.show()
	image = picture

func add_date():
	var date = Time.get_datetime_dict_from_system()
	top.text += str(date["month"]) + "/" + str(date["day"]) + "/" + str(date["year"])

func show_picture():
	image.set_size_override(Vector2i(144, 162))
	photo.texture = image
