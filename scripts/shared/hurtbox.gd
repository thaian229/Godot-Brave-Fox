extends Area2D

@onready var hit_vfx := preload("res://scenes/effects/hit_vfx.tscn") as PackedScene
@export var is_show_hit := false


func _on_area_entered(area: Area2D) -> void:
	# hit vfx at middle of 2 boxes
	self._show_hit_vfx(area)


func _show_hit_vfx(area: Area2D) -> void:
	if not is_show_hit:
		return
	var vfx_instance := hit_vfx.instantiate()
	var world := self.get_tree().current_scene
	world.add_child(vfx_instance)
	vfx_instance.global_position = (self.global_position + area.global_position) * 0.5
