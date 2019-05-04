extends Sprite

var _enabled : bool = false
var _target : Vector2

const DEBUG_TARGETING = false

func _process(delta):
	if DEBUG_TARGETING:
		if _target != null and _enabled:
			self.set_global_position(_target)


func set_target(target : Vector2) -> void:
	if DEBUG_TARGETING:
		_target = target
		_enabled = true
		self.visible = true


func disable() -> void:
	_enabled = false
	self.visible = false
