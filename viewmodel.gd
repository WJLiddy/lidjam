extends SubViewportContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	#$Viewmodel.world_3d = get_viewport().world_3d


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$Viewmodel/Camera3D.global_position = get_node("../World/World/Player/HeadPosition/LandingAnimation/Camera3D").global_position
	$Viewmodel/Camera3D.global_rotation = get_node("../World/World/Player/HeadPosition/LandingAnimation/Camera3D").global_rotation
	
func ads_enable():
	$Viewmodel/Camera3D/AnimationPlayer.play("ads_engage")

func ads_disable():
	$Viewmodel/Camera3D/AnimationPlayer.play("ads_disengage")
	
