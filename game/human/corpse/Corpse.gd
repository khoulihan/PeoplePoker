extends Sprite

func configure(player):
	var skin = player.skin
	var sex = player.sex
	var back = player.is_death_facing_back()
	var flip = player.is_death_flip()
	
	# TODO: Duplicating the materials probably only needs to be done the first time
	# TODO: I'd imagine this could be optimised by creating one material for each skintone as well...
	self.material = self.material.duplicate(true)
	self.material.set_shader_param("skin_type", skin)
	self.flip_h = flip
	
	if back:
		if sex == 0:
			self.frame = 33
		else:
			self.frame = 73
	else:
		if sex == 0:
			self.frame = 13
		else:
			self.frame = 53
