extends Node

class_name PlayerProfile

var base_damage : float = 1
var crit_damage : float = 2
var crit_range : float = 0.5
var scale : float = 1 
var recharge_speed : float
var ammo : int = 6

#func exportar datos -> diccionario:


func import_data(file : Dictionary):
	base_damage = file["damage"]
	crit_damage = file["crit_damage"]
	crit_range = file["crit_range"]
	scale = file["scale"]
	recharge_speed = file["recharge_speed"]
	ammo = file["ammo"]
	pass

var archivo : Dictionary = {
	"damage" : 24,
	"crit_damage" : 24,
	"crit_range" : 24,
	"scale" : 2,
	"recharge_speed" : 2,
	"ammo" : 3
	}
