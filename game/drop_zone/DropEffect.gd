extends Sprite

func _ready():
	$AnimationPlayer.play("Drop")

func set_height(height : float) -> void:
	# Set the y offset
	self.offset.y = -127 - height