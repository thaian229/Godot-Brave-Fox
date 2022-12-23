extends Control

@export var max_hearts := 4
@export var hearts := 3

@onready var rect_empty := $HeartsEmpty as TextureRect
@onready var rect_full := $HeartsFull as TextureRect


func _ready() -> void:
	self._update_ui()
	# connect signals
	PlayerState.connect("max_health_changed", Callable(self, "_on_max_hearts_changed"))
	PlayerState.connect("health_changed", Callable(self, "_on_hearts_changed"))


func _update_ui() -> void:
	rect_empty.size.x = max_hearts * 15
	rect_full.size.x = hearts * 15


func _on_max_hearts_changed(v: int) -> void:
	max_hearts = v
	self._update_ui()


func _on_hearts_changed(v: int) -> void:
	hearts = v
	self._update_ui()
