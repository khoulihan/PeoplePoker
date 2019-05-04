extends Node2D

signal speech_timed_out

const HUMAN_OFFSET = Vector2(-22.0, -38.0)

var _displayed = false

func _ready():
	self.visible = false

func is_displayed() -> bool:
	return _displayed

func display_speech(speech : String, duration : float, world_position : Vector2) -> void:
	self.position = world_position + HUMAN_OFFSET
	$Control/VBoxContainer/Speech.text = speech
	_displayed = true
	self.visible = true
	$Timer.start(duration)

func _on_Timer_timeout():
	_displayed = false
	self.visible = false
	emit_signal("speech_timed_out")
