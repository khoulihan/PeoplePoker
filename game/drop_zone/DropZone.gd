extends Area2D

const DROP_HEIGHT = 100.0
const MAX_HEIGHT = 320.0

export(float) var tracking_drop_rate = 50.0
export(float) var terminal_drop_rate = 200.0

signal drop_updated(pos, height)
signal terminal_drop_initiated(pos, height)
signal drop_completed(pos)

enum State {
	IDLE,
	TRACKING,
	DROPPING,
	RETREATING
}

var _target
var _tracked_position
var _state
var _current_height = 320.0

func _ready():
	pass


func _physics_process(delta):
	if _state == State.IDLE:
		_process_idle(delta)
	elif _state == State.TRACKING:
		_process_tracking(delta)
	elif _state == State.RETREATING:
		_process_retreating(delta)
	elif _state == State.DROPPING:
		_process_dropping(delta)


func _process_idle(delta):
	if _target != null:
		# Just have to check if the target is in cover, and if not, switch to tracking
		# Note, this may start tracking immediately after previous drop completion, so may want to introduce a delay
		if !_target.is_in_cover():
			_tracked_position = _target.position
			_state = State.TRACKING


func _process_tracking(delta):
	if _target == null:
		_state = State.RETREATING
	else:
		_current_height -= tracking_drop_rate * delta
		
		_tracked_position = _tracked_position.linear_interpolate(_target.position, 0.05)
		emit_signal("drop_updated", _tracked_position, _current_height)
		if _current_height <= DROP_HEIGHT:
			_state = State.DROPPING
			emit_signal("terminal_drop_initiated", _tracked_position, _current_height)


func _process_retreating(delta):
	_current_height += terminal_drop_rate * delta
	emit_signal("drop_updated", _tracked_position, min(_current_height, MAX_HEIGHT))
	if _current_height >= MAX_HEIGHT:
		_state = State.IDLE


func _process_dropping(delta):
	_current_height -= terminal_drop_rate * delta
	if _target != null:
		_tracked_position = _tracked_position.linear_interpolate(_target.position, 0.04)
	emit_signal("drop_updated", _tracked_position, max(_current_height, 0.0))
	if _current_height <= 0.0:
		_state = State.IDLE
		_current_height = 320.0
		emit_signal("drop_completed", _tracked_position)


func disable():
	for child in self.get_children():
		child.disabled = true

func enable():
	for child in self.get_children():
		child.disabled = false


func _on_DropZone_body_entered(body):
	if body.has_method("enter_drop_zone"):
		body.enter_drop_zone()
		_target = body
		_connect_target_signals()
		if _state != State.DROPPING:
			_tracked_position = _target.position
			_state = State.TRACKING


func _on_DropZone_body_exited(body):
	if body.has_method("exit_drop_zone"):
		body.exit_drop_zone()
		if _target != null:
			_disconnect_target_signals()
			_target = null
			if _state != State.DROPPING:
				_state = State.RETREATING


func _connect_target_signals():
	_target.connect("entered_cover", self, "_target_entered_cover")
	_target.connect("exited_cover", self, "_target_exited_cover")


func _disconnect_target_signals():
	_target.disconnect("entered_cover", self, "_target_entered_cover")
	_target.disconnect("exited_cover", self, "_target_exited_cover")


func _target_entered_cover():
	if _state == State.TRACKING:
		_state = State.RETREATING


func _target_exited_cover():
	if _state == State.IDLE or _state == State.RETREATING:
		_state = State.TRACKING
