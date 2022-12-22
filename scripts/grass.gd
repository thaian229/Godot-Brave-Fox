class_name Grass
extends Node2D

@onready var grass_vfx := preload("res://scenes/effects/grass_wither_vfx.tscn") as PackedScene
@onready var vfx_instance := grass_vfx.instantiate() as AnimatedSprite2D


func _on_hurtbox_area_entered(_area: Area2D) -> void:
	var world = get_tree().current_scene
	world.add_child(vfx_instance)
	vfx_instance.global_position = self.global_position
	self.call_deferred("queue_free")
