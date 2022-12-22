class_name Grass
extends Node2D

@onready var grass_vfx := load("res://scenes/effects/grass_wither_vfx.tscn") as PackedScene
@onready var vfx_instance := grass_vfx.instantiate() as Node2D

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("attack"):
		var world = get_tree().current_scene
		world.add_child(vfx_instance)
		vfx_instance.global_position = self.global_position
		self.queue_free()
