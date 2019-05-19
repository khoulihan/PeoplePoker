extends Node2D

const MAX_RADIUS = 60.0
const MIN_RADIUS = 30.0
const MAX_ALPHA = 0.75
const MIN_ALPHA = 0.0
const MAX_HEIGHT = 320.0
const ELLIPSE_FACTOR = 0.65

var _radius : float
var _color : Color = Color("#08102b")

func _ready():
	_radius = 0.0
	_color.a = 0.5

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

func set_height(height : float) -> void:
	# Set radius and transparency based on height range
	var inverse : float = MAX_HEIGHT - height
	_radius = MIN_RADIUS + ((MAX_RADIUS - MIN_RADIUS) / MAX_HEIGHT) * height
	_color.a = MIN_ALPHA + ((MAX_ALPHA - MIN_ALPHA) / MAX_HEIGHT) * inverse #(MAX_ALPHA / MAX_HEIGHT) * inverse
	
	update()

func centre_on_position(pos : Vector2, height : float) -> void:
	set_height(height)
	self.position = pos + Vector2(0.0, _radius * ELLIPSE_FACTOR)