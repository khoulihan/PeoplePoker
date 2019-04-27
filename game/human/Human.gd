extends Node2D

export(int, "Male", "Female") var sex : int
export(float) var walk_speed
export(float) var run_speed

func _ready():
	if self.sex == 0:
		$Female.visible = false
	else:
		$Male.visible = false


func _process(delta):
	# TODO: Random walk behaviour for NPCs
	pass