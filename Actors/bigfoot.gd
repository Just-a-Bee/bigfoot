extends Node3D

#!!!!!!!! Available animations are currently:
#"run", "walk-slow", "walk-normal"

@onready var animationplayer :AnimationPlayer = $AnimationPlayer
@onready var mesh :MeshInstance3D = $"rig/Skeleton3D/bigfoot-base"

enum faces {angry1,angry2,eek,smile,looksmaxxing}

const face_textures = [\
preload("res://3d/textures/bigfoot-skin-faces/bigfoot-face-angry-1.png"),\
preload("res://3d/textures/bigfoot-skin-faces/bigfoot-face-angry-2.png"),\
preload("res://3d/textures/bigfoot-skin-faces/bigfoot-face-eek.png"),\
preload("res://3d/textures/bigfoot-skin-faces/bigfoot-face-smile.png"),\
preload("res://3d/textures/bigfoot-skin-faces/bigfoot-face-looksmaxxing.png")\
]

func _ready() -> void:
	mesh.set_surface_override_material\
	(1, load("res://3d/materials/bigfoot-skin.tres"))
	play_anim("run")

#play a looping animation 
func play_anim(animation_name:String) ->void:
	var anim = animationplayer.get_animation(animation_name)
	anim.loop_mode = Animation.LOOP_LINEAR
	animationplayer.play(animation_name)

#switch to a face from the faces enum
func switch_face(new_face:faces) ->void:
	var mat = mesh.get_surface_override_material(1)
	#print(mat)
	if mat is ShaderMaterial:
		mat.set_shader_parameter("col_map", face_textures[new_face])
