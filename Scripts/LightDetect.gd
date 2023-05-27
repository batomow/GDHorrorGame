extends Node3D

var light_level : float

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var mesh_instance := get_node("MeshInstance3D")
	get_node("SubViewportContainer/SubViewport/Camera3D").global_position = Vector3(mesh_instance.global_position.x, mesh_instance.global_position.y + 0.3, mesh_instance.global_position.z)
	var image :Image = get_node("SubViewportContainer/SubViewport").get_texture().get_image()
	var floats :Array[float]
	for y in range(image.get_height()): 
		for x in range(image.get_width()): 
			var pixel = image.get_pixel(x, y)
			var light_value = (pixel.r + pixel.g + pixel.b)/3.0
			floats.push_back(light_value)
	light_level = average(floats)

func average(numbers:Array[float])->float: 
	var count:float = numbers.size()
	var sum:float = numbers.reduce( func (accum, val): return accum + val, 0.0)
	return sum / float(count)
