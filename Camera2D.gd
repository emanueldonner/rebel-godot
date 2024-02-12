extends Camera2D

var camera_pan_speed: float = 100
var camera_offset: Vector2 = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _input(event):
	if event.is_action_pressed("camera_up"):
		print("camera_up")
		camera_offset.y -= camera_pan_speed
	if event.is_action_pressed("camera_down"):
		camera_offset.y += camera_pan_speed
	if event.is_action_pressed("camera_left"):
		camera_offset.x -= camera_pan_speed
	if event.is_action_pressed("camera_right"):
		camera_offset.x += camera_pan_speed

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
