class_name WanderController
extends Node2D

signal wander_target_changed

@export var wander_range := 50
@export var stopping_distance := 5

@onready var timer := $Timer as Timer
@onready var original_position := self.global_position
@onready var target_position := self.global_position


func _ready() -> void:
	timer.start(1.0)


func change_wander_target() -> void:
	target_position = original_position + Vector2( randf_range(-wander_range, wander_range), randf_range(-wander_range, wander_range) )
	self.emit_signal("wander_target_changed")


func _on_timer_timeout():
	self.change_wander_target()
	timer.start(randf_range(2.0, 4.0))
