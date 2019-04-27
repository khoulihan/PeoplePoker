extends Node2D

func _ready():
	pass


func _on_CoverArea_body_entered(body):
	if body.has_method("enter_cover"):
		body.enter_cover()


func _on_CoverArea_body_exited(body):
	if body.has_method("exit_cover"):
		body.exit_cover()
