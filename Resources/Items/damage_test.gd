extends Item

func use() -> void:
	update_level()
	player_profile.base_damage += 1
	print("el nivel actual es: ", lv)
