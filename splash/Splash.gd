extends Node2D

func _ready():
	WindowController.resize_window()


func _on_BeatTimer_timeout():
	$AudioStreamPlayer.play()


func _on_StartTimer_timeout():
	pass # TODO: Transition to game/menu/whatever
