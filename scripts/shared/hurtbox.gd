extends Area2D

@export var is_show_hit := false
@export var has_ghosting := false
@export var ghosting_duration := 2.0

@onready var hit_vfx := preload("res://scenes/effects/hit_vfx.tscn") as PackedScene
@onready var ghost_timer := $GhostingTimier as Timer

func _on_area_entered(area: Area2D) -> void:
	# hit vfx at middle of 2 boxes
	self._show_hit_vfx(area)
	# activate ghosting
	if has_ghosting:
		self.set_deferred("monitoring", false)
		ghost_timer.start(ghosting_duration)
	


func _show_hit_vfx(area: Area2D) -> void:
	if not is_show_hit:
		return
	var vfx_instance := hit_vfx.instantiate()
	var world := self.get_tree().current_scene
	world.add_child(vfx_instance)
	vfx_instance.global_position = (self.global_position + area.global_position) * 0.5


func _on_ghosting_timier_timeout():
	self.set_deferred("monitoring", true)
