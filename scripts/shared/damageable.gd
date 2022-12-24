class_name Damageable
extends Node

signal zero_health()

@export var max_health := 1

@onready var current_health := max_health :
	get: return current_health
	set(v):
		current_health = clampi(v, 0, max_health)
		if current_health < 1:
			self.emit_signal("zero_health")
