extends Node2D

func _ready():
	pass


func _on_CoverArea_body_entered(body):
	if body.has_method("entered_cover"):
		body.entered_cover()


func _on_CoverArea_body_exited(body):
	if body.has_method("exited_cover"):
		body.exited_cover()
