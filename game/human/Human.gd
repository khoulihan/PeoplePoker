extends KinematicBody2D

export(int, "Male", "Female") var sex : int
export(float) var walk_speed
export(float) var run_speed

var _back : bool

func _ready():
	pass


func configure():
	var skin = randi() % 3
	_back = (randi() % 2 == 0)
	var flip = (randi() % 2 == 0)
	
	# TODO: Duplicating the materials probably only needs to be done the first time
	if self.sex == 0:
		$Female.visible = false
		$Male.visible = true
		$Male.material = $Male.material.duplicate(true)
		$Male.material.set_shader_param("skin_type", skin)
		$Male.flip_h = flip
	else:
		$Male.visible = false
		$Female.visible = true
		$Female.material = $Female.material.duplicate(true)
		$Female.material.set_shader_param("skin_type", skin)
		$Female.flip_h = flip
	
	if _back:
		$AnimationPlayer.play("IdlePenBack")
	else:
		$AnimationPlayer.play("IdlePenFront")


func _process(delta):
	# TODO: Random walk behaviour for NPCs
	pass