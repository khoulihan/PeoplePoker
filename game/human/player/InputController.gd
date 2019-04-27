extends Node

export(float) var deadzone = 0.3;

onready var _movement_vector = Vector2(0.0, 0.0)

var _run : bool = false
var _roll : bool = false

func get_movement() -> Vector2:
	return _movement_vector.normalized()

func get_run() -> bool:
	return _run

func get_roll() -> bool:
	return _roll

func _process(delta):
	if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
		_movement_vector.x = 1.0
		if Input.is_action_pressed("move_left"):
			_movement_vector.x *= -1.0
	else:
		_movement_vector.x = 0.0
	
	if Input.is_action_pressed("move_up") or Input.is_action_pressed("move_down"):
		_movement_vector.y = 1.0
		if Input.is_action_pressed("move_up"):
			_movement_vector.y *= -1.0
	else:
		_movement_vector.y = 0.0
	
	_run = Input.is_action_pressed("run")
	_roll = Input.is_action_just_pressed("roll")
