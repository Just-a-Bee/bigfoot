extends CollisionShape3D


# Called when the node enters the scene tree for the first time.
func _ready():
	var heightmap_texture: Texture = ResourceLoader.load("res://3d/heightmap-40-units.png")
	var heightmap_image: Image = heightmap_texture.get_image()
	heightmap_image.convert(Image.FORMAT_RF)
	
	# Assign size first, otherwise it won't work
	shape.map_width = heightmap_texture.get_width()
	shape.map_depth = heightmap_texture.get_height()
	
	var height_min: float = 0.0
	var height_max: float = 10.0
	
	shape.update_map_data_from_image(heightmap_image, height_min, height_max)
