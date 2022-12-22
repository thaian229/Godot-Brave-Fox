class_name Hitbox
extends Area2D

@export var damage : int = 1 :
	get: return damage
	set(v):
		damage = clampi(v, 0, 10)
