extends Node

var pictures_to_grade = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	
func _input(event: InputEvent) -> void:
	if(Global.is_using_puter):
		if event is InputEventMouseMotion:
			get_node("Mouse").position.x += event.relative.x / 1000
			get_node("Mouse").position.y -= event.relative.y / 1000
			
		if event is InputEventMouseButton:
			if event.pressed:
				if $Logoff/Logoff.get_overlapping_bodies().size() == 1:
					Global.is_using_puter = false
					get_node("../../Player").action_cooldown = 0.4
				if $Upload/Upload.get_overlapping_bodies().size() == 1:
					$Logoff.visible = false
					$Upload.visible = false
					$Background.visible = false
					pictures_to_grade = Global.pics.duplicate()
					get_node("/root/forest/UIRender").rewind()
			
		# clamp to -.25 to 25
		# 0.15 to 0.45
	get_node("Mouse").position.x = clamp(get_node("Mouse").position.x,-0.25,0.25)
	get_node("Mouse").position.y = clamp(get_node("Mouse").position.y,0.15,0.45)
	
