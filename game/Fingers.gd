extends Node2D

export var target : NodePath

var _target : Camera

func _ready():
	_target = get_node(target)

func _process(delta):
	self.position = _target.get_camera_screen_center()