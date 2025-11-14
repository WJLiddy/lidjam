extends SubViewportContainer

var hidecam = false
var hidewhis = true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Viewmodel/Camera3D/WhistleViewModel.play("hide")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$Viewmodel/Camera3D.global_position = get_node("../World/World/Player/HeadPosition/LandingAnimation/Camera3D").global_position
	$Viewmodel/Camera3D.global_rotation = get_node("../World/World/Player/HeadPosition/LandingAnimation/Camera3D").global_rotation
	
func ads_enable():
	$Viewmodel/Camera3D/CamViewModel.play("ads_engage")
	get_node("../UIRender").photomode = true

func ads_disable():
	$Viewmodel/Camera3D/CamViewModel.play("ads_disengage")
	get_node("../UIRender").photomode = false

func cam_hide():
	if(not hidecam):
		$Viewmodel/Camera3D/CamViewModel.play("hide")
		hidecam = true

func cam_show():
	if(hidecam):
		$Viewmodel/Camera3D/CamViewModel.play("show")
		hidecam = false
		
func whis_hide():
	if(not hidewhis):
		$Viewmodel/Camera3D/WhistleViewModel.play("hide")
		hidewhis = true

func whis_show():
	if(hidewhis):
		$Viewmodel/Camera3D/WhistleViewModel.play("show")
		hidewhis = false
	
