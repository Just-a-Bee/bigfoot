extends Control

@onready var animationPlayer = $AnimationPlayer
@onready var animationPic = $AnimationText/AnimationPic
@onready var animationText = $AnimationText

@onready var picture_slots = [
		$PictureLabel1, $PictureLabel2, $PictureLabel3, $PictureLabel4, 
		$PictureLabel5, $PictureLabel6 , $PictureLabel7, $PictureLabel8
		]

var perfect_score = 10
var okay_score = 5


# Called when the node enters the scene tree for the first time.
func _ready():
	MouseMotion.is_main_loaded = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	do_picture_anim()


func do_picture_anim():
	var total = 0
	var highest_picture = GameData.pictures[0]
	for i in 8:
		var picture = GameData.pictures[i]
		var slot = picture_slots[i]
		animationPic.texture = picture["texture"]
		animationText.text = ""
		animationPlayer.play("show_picture")
		await animationPlayer.animation_finished
		
		
		for s in picture["strings"]:
			animationText.text = animationText.text + s + "\n"
			await get_tree().create_timer(.2).timeout
		
		await get_tree().create_timer(2).timeout
		
		slot.text += str(picture["score"])
		slot.get_node("Picture").texture = picture["texture"]
		total += picture["score"]
		
		# update highest picture
		if picture["score"] > highest_picture["score"]:
			highest_picture = picture
		
	$Total.text += str(total)
	$PublishButton.disabled = false
	
	if total > perfect_score:
		$Newspaper.set_perfect(highest_picture["texture"])
	elif total > okay_score:
		$Newspaper.set_okay(highest_picture["texture"])
	else:
		$Newspaper.set_bad(highest_picture["texture"])
	
	
	

# publish evidence button pressed
func _on_button_button_up():
	$PublishButton.disabled = true
	animationPlayer.play("newspaper")
	


func _on_title_button_up():
	get_tree().change_scene_to_file("res://UI Scenes/title.tscn")
