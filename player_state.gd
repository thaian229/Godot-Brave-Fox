extends Node
# this is a singleton

signal max_health_changed(value: int)
signal health_changed(value: int)
signal zero_health()

var max_health := 3 :
	get: return max_health
	set(v):
		max_health = v if v > 0 else 1
		self.emit_signal("max_health_changed", max_health)

@onready var health := max_health :
	get: return health
	set(v):
		health = clampi(v, 0, max_health)
		self.emit_signal("health_changed", health)
		if health <= 0:
			health = 0
			self.emit_signal("zero_health")
