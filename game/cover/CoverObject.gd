extends Node2D

func _ready():
	pass

func disable():
	$Sprite.visible = false
	$KinematicBody2D/CollisionShape2D.disabled = true
	for shape in $CoverArea.get_children():
		shape.disabled = true

func enable():
	$Sprite.visible = true
	$KinematicBody2D/CollisionShape2D.disabled = false
	for shape in $CoverArea.get_children():
		shape.disabled = false

func _on_CoverArea_body_entered(body):
	if body.has_method("enter_cover"):
		body.enter_cover()


func _on_CoverArea_body_exited(body):
	if body.has_method("exit_cover"):
		body.exit_cover()
