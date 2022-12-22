extends Node2D

@onready var anim_sprite := $AnimatedSprite2D as AnimatedSprite2D


func _ready() -> void:
	anim_sprite.play("default")


func _on_animated_sprite_2d_animation_finished():
	self.call_deferred("queue_free")
