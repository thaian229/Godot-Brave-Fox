class_name TargetDetector
extends Area2D

var target_list := []
var curr_target: Node2D = null

func _process(_delta: float) -> void:
	self._update_target()
	# test
#	if curr_target:
#		print_debug(curr_target.global_position)


func _update_target() -> void:
	var min_distance: float = 1e10
	if target_list.is_empty():
		curr_target = null
	for target in target_list:
		var distance: float = (target.get_parent().global_position - self.global_position).length()
		if distance < min_distance:
			min_distance = distance
			curr_target = target
	return


func _on_body_entered(body: Node2D) -> void:
	if body not in target_list:
		target_list.append(body)


func _on_body_exited(body: Node2D) -> void:
	target_list.erase(body)
