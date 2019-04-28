extends CanvasLayer

signal fade_out_complete
signal fade_in_complete

func _ready():
	fade_out()

var _in : bool

func fade_in():
	_in = true
	$Mask/Tween.interpolate_property($Mask, "color", Color(0.0, 0.0, 0.0, 0.0), Color(0.0, 0.0, 0.0, 1.0), 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Mask/Tween.start()

func fade_out():
	_in = false
	$Mask/Tween.interpolate_property(self, "color", Color(0.0, 0.0, 0.0, 1.0), Color(0.0, 0.0, 0.0, 0.0), 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Mask/Tween.start()


func _on_Tween_tween_completed(object, key):
	if _in:
		$Mask.color = Color(0.0, 0.0, 0.0, 1.0)
		emit_signal("fade_in_complete")
	else:
		$Mask.color = Color(0.0, 0.0, 0.0, 0.0)
		emit_signal("fade_out_complete")
