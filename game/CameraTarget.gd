extends Node2D

var _target : Node2D

func follow(t) -> void:
	_target = t

func _ready():
	pass

func _process(delta):
	if _target != null:
		self.position = _target.position
