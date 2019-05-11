extends StaticBody2D

func disable():
	$Sprite.visible = false
	$CollisionShape2D.disabled = true
	$CollisionShape2D2.disabled = true

func enable():
	$Sprite.visible = true
	$CollisionShape2D.disabled = false
	$CollisionShape2D2.disabled = false
