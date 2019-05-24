extends Node2D

const DROP_HEIGHT = 100.0
const MAX_HEIGHT = 320.0
const MAX_RADIUS = 60.0
const MIN_RADIUS = 30.0
const MAX_ALPHA = 0.75
const MIN_ALPHA = 0.0
const ELLIPSE_FACTOR = 0.65

export(float) var tracking_drop_rate = 75.0
export(float) var terminal_drop_rate = 200.0

enum State {
	IDLE,
	TRACKING,
	DROPPING,
	RETREATING
}

signal drop_updated(pos, height)
signal terminal_drop_initiated(pos, height)
signal drop_completed(pos)

var _radius : float
var _color : Color = Color("#08102b")

var _target
var _tracked_position
var _state
var _current_height = 320.0

func _ready():
	_radius = 0.0
	_color.a = 0.5
	_state = State.IDLE

func _draw():
	#var screen_coord = get_viewport_transform() * (get_global_transform() * self.position)
	#draw_circle(screen_coord, 25.0, Color.white)
	#draw_circle(self.position, 25.0, Color.white)
	#draw_circle(Vector2(), 25.0, Color.white)
	draw_ellipse(Vector2(0.0, -_radius * ELLIPSE_FACTOR), _radius, _color)


func draw_ellipse(center, radius, color):
	var nb_points = 32.0
	var points_arc = PoolVector2Array()
	#points_arc.push_back(center)
	var colors = PoolColorArray([color])
	
	for i in range(nb_points):
		var angle_point = ((PI * 2.0) / nb_points) * i
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point) * ELLIPSE_FACTOR) * radius)
		#colors.push_back(color)
	draw_polygon(points_arc, colors)

func hide() -> void:
	_color.a = 0.0
	update()

func set_target(t) -> void:
	_target = t

func set_height(height : float) -> void:
	# Set radius and transparency based on height range
	var inverse : float = MAX_HEIGHT - height
	_radius = MIN_RADIUS + ((MAX_RADIUS - MIN_RADIUS) / MAX_HEIGHT) * height
	_color.a = MIN_ALPHA + ((MAX_ALPHA - MIN_ALPHA) / MAX_HEIGHT) * inverse #(MAX_ALPHA / MAX_HEIGHT) * inverse
	
	update()

func centre_on_position(pos : Vector2, height : float) -> void:
	set_height(height)
	self.position = pos + Vector2(0.0, _radius * ELLIPSE_FACTOR)


func _physics_process(delta):
	if _state == State.IDLE:
		print("Idle")
		_process_idle(delta)
	elif _state == State.TRACKING:
		print("Tracking")
		_process_tracking(delta)
	elif _state == State.RETREATING:
		print("Retreating")
		_process_retreating(delta)
	elif _state == State.DROPPING:
		print("Dropping")
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
		self.centre_on_position(_tracked_position, _current_height)
		emit_signal("drop_updated", _tracked_position, _current_height)
		if _current_height <= DROP_HEIGHT:
			_state = State.DROPPING
			emit_signal("terminal_drop_initiated", _tracked_position, _current_height)


func _process_retreating(delta):
	_current_height += terminal_drop_rate * delta
	self.centre_on_position(_tracked_position, min(_current_height, MAX_HEIGHT))
	emit_signal("drop_updated", _tracked_position, min(_current_height, MAX_HEIGHT))
	if _current_height >= MAX_HEIGHT:
		_state = State.IDLE


func _process_dropping(delta):
	_current_height -= terminal_drop_rate * delta
	if _target != null:
		_tracked_position = _tracked_position.linear_interpolate(_target.position, 0.04)
	self.centre_on_position(_tracked_position, max(_current_height, 0.0))
	emit_signal("drop_updated", _tracked_position, max(_current_height, 0.0))
	if _current_height <= 0.0:
		_state = State.IDLE
		_current_height = 320.0
		emit_signal("drop_completed", _tracked_position)