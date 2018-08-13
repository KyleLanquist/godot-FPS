extends Spatial

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta):
	if (Input.is_action_just_pressed("ui_cancel")):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().quit()
	if (Input.is_action_just_pressed("restart")):
		get_tree().reload_current_scene()
		
func _input(event):
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
