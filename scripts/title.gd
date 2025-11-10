extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#_on_button_pressed()
	pass # Replace with function body.

func _on_button_pressed() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Global.is_on_title = false
	get_node("../World/World/Player/HeadPosition/LandingAnimation/Camera3D").current = true
	get_node("../World/World/IntroCam").current = false
	get_node("../UIRender").visible = true
	get_node("../ViewModel").visible = true
	queue_free()
