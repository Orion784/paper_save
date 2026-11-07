extends Resource

class_name Item

@export var id : int
@export var name : String
@export var description: String
@export var icon : Texture2D
@export var locked : bool
@export var lv : int
@export var values : Array
@export var player_profile : PlayerProfile
@export var shop_profile : Profile
@export var ufo_profile : UfoProfile

func use() -> void:
	pass

func update_level() -> bool:
	if lv < 3:
		lv +=1
		return true
	return false
