extends Control

signal speech_timed_out

const HUMAN_OFFSET = Vector2(-22.0, -38.0)

var _displayed = false
var _world_position
var _game_viewport_transform
var _game_global_transform

func _ready():
	self.visible = false

func _process(delta):
	#self.rect_position = get_viewport_transform() * (get_global_transform() * (_world_position + HUMAN_OFFSET))
	#self.rect_global_position = _world_position + HUMAN_OFFSET
	self.rect_position = _game_viewport_transform * (_game_global_transform * (_world_position + HUMAN_OFFSET))

func update_transforms(viewport, global):
	_game_global_transform = global
	_game_viewport_transform = viewport

func is_displayed() -> bool:
	return _displayed

func display_speech(speech : String, duration : float, world_position : Vector2) -> void:
	_world_position = world_position
	self.rect_position = _game_viewport_transform * (_game_global_transform * (_world_position + HUMAN_OFFSET))
	$VBoxContainer/Speech.text = speech
	_displayed = true
	self.visible = true
	$Timer.start(duration)

func _on_Timer_timeout():
	_displayed = false
	self.visible = false
	emit_signal("speech_timed_out")
