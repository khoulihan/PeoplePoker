extends Node2D

var _target : Node2D
onready var _camera = get_node("Camera")
var _shake

func follow(t) -> void:
	_target = t

func _ready():
	pass

func _physics_process(delta):
	if _target != null:
		self.position = Vector2(round(_target.position.x), round(_target.position.y))

func _process(delta):
	if _shake != null:
		_shake = _shake.resume()

func shake(duration):
	var t = OS.get_ticks_msec()
	var end = t + duration * 1000.0
	while t < end:
		_camera.offset = Vector2(randi() % 3, randi() % 3)
		yield(get_tree(), "idle_frame")
		t = OS.get_ticks_msec()
	