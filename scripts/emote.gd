extends Node3D

var follow
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var tween = get_tree().create_tween()
	
	# Step 1: Stretch on X
	tween.tween_property(self, "scale", Vector3(1.0, 1.0, 1.0), 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	# Step 2: Wobble back and forth
	tween.tween_property(self, "scale", Vector3(0.8, 1.2, 1.0), 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "scale", Vector3(1.1, 0.9, 1.0), 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "scale", Vector3(1.0, 1.0, 1.0), 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	# Step 3: Fade out and disappear
	tween.tween_property($Anger, "modulate:a", 0.0, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property($Scared, "modulate:a", 0.0, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property($Alert, "modulate:a", 0.0, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property($Love, "modulate:a", 0.0, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_callback(Callable(self, "queue_free"))

func set_type(st):
	$Anger.visible = st == "Anger"
	$Love.visible = st == "Love"
	$Alert.visible = st == "Alert"
	$Scared.visible = st == "Scared"
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	look_at(get_node("../../Player").global_position)
	global_position = follow.global_position + Vector3(0,1,0)
