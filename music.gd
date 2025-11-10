extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

var tracktimer = 10
var TRACK_CHANGE_TIME = 5

var currplaying = "Spawn"
var nexttrack = "Spawn"


	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var tracks = {
		"Spawn": $Spawn/Track,
		"Forest": $Forest/Track,
		"Graveyard": $Graveyard/Track,
		"Ocean": $Ocean/Track
	}
	tracktimer -= delta
	if(tracktimer < 0):
		tracktimer = TRACK_CHANGE_TIME
		if(currplaying == nexttrack):
			return

		var trackold = tracks[currplaying]
		var t := get_tree().create_tween()
		t.tween_property(trackold, "volume_db", -80, 3.0)
		t.tween_callback(Callable(trackold, "stop"))
		
		currplaying = nexttrack
		var tracknew = tracks[currplaying]
		var t2 := get_tree().create_tween()
		tracknew.play()
		t2.tween_property(tracknew, "volume_db", -20, 2.0)


func _on_spawn_body_entered(_body: Node3D) -> void:
	nexttrack = "Spawn"
	tracktimer = TRACK_CHANGE_TIME 

func _on_forest_body_entered(_body: Node3D) -> void:
	nexttrack ="Forest"
	tracktimer = TRACK_CHANGE_TIME 

func _on_graveyard_body_entered(_body: Node3D) -> void:
	nexttrack = "Graveyard"
	tracktimer = TRACK_CHANGE_TIME 

func _on_ocean_body_entered(_body: Node3D) -> void:
	nexttrack = "Ocean"
	tracktimer = TRACK_CHANGE_TIME 
