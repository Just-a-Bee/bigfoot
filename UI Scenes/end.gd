extends Control

@onready var animationPlayer = $AnimationPlayer
@onready var animationPic = $AnimationText/AnimationPic
@onready var animationText = $AnimationText

@onready var picture_slots = [
		$PictureLabel1, $PictureLabel2, $PictureLabel3, $PictureLabel4, 
		$PictureLabel5, $PictureLabel6 , $PictureLabel7, $PictureLabel8
		]

var model_score = 30
var perfect_score = 15
var okay_score = 10


# Called when the node enters the scene tree for the first time.
func _ready():
	MouseMotion.is_main_loaded = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	do_picture_anim()
	$FileDialog.add_filter("*.png")
	$FileDialog.add_filter("*.jpeg")
	$FileDialog.add_filter("*.jpg")


func do_picture_anim():
	var total = 0
	var highest_picture = GameData.pictures[0]
	var lowest_picture = GameData.pictures[0]
	for i in 8:
		var picture = GameData.pictures[i]
		var slot = picture_slots[i]
		animationPic.texture = picture["texture"]
		animationText.text = ""
		animationPlayer.play("show_picture")
		await animationPlayer.animation_finished
		
		
		for s in picture["strings"]:
			animationText.text = animationText.text + s + "\n"
			if s == "Bad.":
				$BadScoring.play()
			else:
				$GoodScoring.play()
			await get_tree().create_timer(.2).timeout
		
		await get_tree().create_timer(2).timeout
		animationPlayer.play("hide_picture")
		await animationPlayer.animation_finished
		
		slot.text += str(picture["score"])
		slot.get_node("Picture").texture = picture["texture"]
		total += picture["score"]
		
		# update highest picture
		if picture["score"] > highest_picture["score"]:
			highest_picture = picture
		elif picture["score"] < lowest_picture["score"]:
			lowest_picture = picture
	
	$Total.text += str(total)
	$PublishButton.disabled = false
	
	if total > model_score:
		$Newspaper.set_model(highest_picture["texture"])
	elif total > perfect_score:
		$Newspaper.set_perfect(highest_picture["texture"])
	elif total > okay_score:
		$Newspaper.set_okay(highest_picture["texture"])
	else:
		$Newspaper.set_bad(lowest_picture["texture"])
	
	
	

# publish evidence button pressed
func _on_button_button_up():
	$PublishButton.disabled = true
	animationPlayer.play("newspaper")
	


func _on_title_button_up():
	get_tree().change_scene_to_file("res://UI Scenes/title.tscn")


func _on_button_1_button_up():
	save_picture(picture_slots[0])
func _on_button_2_button_up():
	save_picture(picture_slots[1])
func _on_button_3_button_up():
	save_picture(picture_slots[2])
func _on_button_4_button_up():
	save_picture(picture_slots[3])
func _on_button_5_button_up():
	save_picture(picture_slots[4])
func _on_button_6_button_up():
	save_picture(picture_slots[5])
func _on_button_7_button_up():
	save_picture(picture_slots[6])
func _on_button_8_button_up():
	save_picture(picture_slots[7])

var save_image = null
func save_picture(slot):
	var texture = slot.get_node("Picture").texture
	save_image = texture.get_image()
	
	if OS.has_feature("web"):
		var buffer = save_image.save_png_to_buffer()
		JavaScriptBridge.download_buffer(buffer, "%s.png" % "bigfoot", "image/png")
	else:
		$FileDialog.current_file = "Bigfoot.png"
		$FileDialog.show()

func _on_file_dialog_file_selected(path):
	
	if path.get_extension() == "png":
		save_image.save_png(path)
	elif path.get_extension() == "jpeg" or path.get_extension() == "jpg":
		save_image.save_jpg(path)
