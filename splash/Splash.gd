extends Node2D

func _ready():
	WindowController.resize_window()


func _on_BeatTimer_timeout():
	$AudioStreamPlayer.play()
	$StartTimer.start()


func _on_StartTimer_timeout():
	FadeMask.connect("fade_in_complete", self, "_fade_in_complete")
	FadeMask.fade_in()

func _fade_in_complete():
	FadeMask.disconnect("fade_in_complete", self, "_fade_in_complete")
	self.get_tree().change_scene("res://game/Game.tscn")
	FadeMask.fade_out()
	