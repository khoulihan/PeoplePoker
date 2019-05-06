extends Node2D

var _target : Node2D

func follow(t) -> void:
	_target = t

func _ready():
	pass

func _physics_process(delta):
	if _target != null:
		self.position = Vector2(round(_target.position.x), round(_target.position.y))

