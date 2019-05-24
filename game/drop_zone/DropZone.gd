extends Area2D

func disable():
	for child in self.get_children():
		child.disabled = true

func enable():
	for child in self.get_children():
		child.disabled = false


func _on_DropZone_body_entered(body):
	if body.has_method("enter_drop_zone"):
		body.enter_drop_zone()


func _on_DropZone_body_exited(body):
	if body.has_method("exit_drop_zone"):
		body.exit_drop_zone()
