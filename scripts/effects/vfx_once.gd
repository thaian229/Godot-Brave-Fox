extends AnimatedSprite2D


func _ready() -> void:
	self.connect("animation_finished", Callable(self, "_on_animation_finished"))
	self.play("default")


func _on_animation_finished():
	self.call_deferred("queue_free")
