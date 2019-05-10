extends Camera2D

var _target : Node2D
onready var _camera = get_node("Camera")

func _ready():
	pass

func follow(t) -> void:
	_target = t

func _process(delta):
	pass