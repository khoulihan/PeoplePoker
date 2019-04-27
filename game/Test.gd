extends Sprite

export var target : NodePath

var _target : Node2D

func _ready():
	_target = get_node(target)

func _process(delta):
	self.position = _target.get_camera_screen_center()
